// reclosable baggie drain & dry hanger
// Brian K. White - b.kenyon.w@gmail.com
//
// Uses chopsticks for both the hangers and the hinge.
// You want 6mm round style chopsticks. Typical example:
// https://www.hlybamboo.com/products/bamboo-chopsticks/disposable-bamboo-chopstick/round-bamboo-chopstick/round-bamboo-chopsticks-bulk/
// You can also use 5mm chopsticks by setting sd=5, or skewers by setting sd=3.
//
// printing notes:
// * The swing arm parts have very little surface area contacting the bed, and need help staying in place.
//   You can avoid using a brim by using support:
//   overhang angle 40, touching build plate only, top Z 0.2mm, Z overrides XY
// * The top few layers are small and need more time to solidify before the next layer.
//   Set minimum layer time to at least 10 seconds.

// TODO & ideas
// * Variant with one-piece hinge bracket. Bores open all the way through top & bottom, bottom hole is smaller. You insert a full stick from the top, pointed end down. Less flexible, but much simpler installation.
// * spacers or hooks that slip onto the sticks to hang several things on one stick and hold them apart from each other. For things that are flat and hang down, not baggies.
// * baked-in bed adhesion structure for the arms instead of relying on user slicer settings.
// * support rectangular sticks

// stick diameter - Chopsticks: 6 or 5  Skewers: 3
sd = 6;

// number of sticks
ns = 6;

// fitment clearance - Adjust this (not stick diameter) if the sticks are too tight or too loose. Set this so that the sticks fit snugly into the swing arms, and don't quite fit into the hinge end cap brackets. The end caps will always be too tight because of the unsupported overhang inside the pocket. For the hinge, cut or sand a small flat into each end of the stick.
fc = 0.2;

// wall thickness - around the bores, also wall plate thickness
wt = 1;


// stick angle - some math below really only works for values about 32 to 58
sa = 45+0; // +0 = hide from thingiverse configurator
// fillet radius - where the hinge meets the wall plate
fr = 2;

// Command(tm) strip refills, size small
//https://www.command.com/3M/en_US/command/products/~/Command-Clear-Small-Refill-Strips/?N=5924736+3294529207+3294737336
//https://www.command.com/3M/en_US/command/products/~/Command-Outdoor-Small-Refill-Strips/?N=5924736+3293833403+3294529207

// Command(tm) strip width - small=15 med & large=19
cw = 16;
// Command(tm) strip length - small=46 med=70 large=95
cl = 46;
ct = 0.3+0; // Command(tm) strip thickness

o = 0.01+0; // union/difference overlap/overhang
$fn = 72+0; // arc smoothness


// calculated values
id = fc+sd+fc; // id of stick bores
od = wt+id+wt; // od around stick bores

// right angle stuff related to the arm od and stick angle
a = od*sin(sa);
b = sqrt(od*od-a*a);
h = (a*b)/od;
hh = h*2.9; // hinge height - H*2.9 = arms nest and just clear each other
pl = h*5;   // pocket length - stick pocket depth

po_min = od/2+wt+fc; // minimum pin offset - hinge center to wall surface
// extra pin offset - Extra space between the wall and the hinge. You might want this if you put some kind of knob or T on the ends of the sticks, you can use this to bring the hinge pin out away from the wall to make the sticks parallel with the wall again.
po_extra = 0;
po = po_min+po_extra;


//  OUTPUT
///////////////////////////////////////////////////////////////////////////

print_kit();  // export all the parts for a kit, arranged for printing
translate([pl*2-cw/2,hh*5,cw/2]) %assembly(); // display all the parts assembled
//arm();  // export just an arm
//bracket();  // export just a bracket

///////////////////////////////////////////////////////////////////////////


module print_kit () {
 s = 1; // part seperation
 y = od+s; // arm spacing
 bx = pl+od/2+cw/2; // brackets x offset
 
 for (i=[0:1:ns-1])
  translate([0,y*i,0]) arm();

 translate([bx,cw/2,0]) bracket();
 translate([bx+s+cw,cw/2,0]) bracket();
}

module assembly() {
 v = hh+0.05; // vertical spacing

 for (i=[1:1:ns])
  translate([0,0,v*i]) arm();

 translate([0,po,hh+v*(ns+1)])
  rotate([90,180,00]) {
   bracket();
   %command_strip();
  }
 translate([0,po,0])
  rotate([90,0,0]) {
   bracket();
   %command_strip();
  }
}

module arm () {
 x = h-wt; // bottom cut elevation
 translate([0,0,-x])
  difference() {
   union() {
    difference() {
     union() {
      hull() {
       cylinder(h=pl,d=od); // hinge od before cut
       rotate([0,sa,0])
        translate([0,0,h])
         cylinder(h=pl,d=od); // arm od before cut
      }
     }

     group () {
      translate([-(o+od+o)/2,-(o+od+o)/2,-h+x])
       cube([od*2,o+od+o,h]); // arm bottom cut
      translate([-(o+od+o)/2,-(o+od+o)/2,hh+x])
       cube([pl*1.5,o+od+o,pl]); // arm top cut
     }
    }

    rotate([0,sa,0])
     translate([0,0,a+h])
      cylinder(h=pl-a,d=od); // arm od after cut
   }

   group() {
    translate([0,0,x-o])
     cylinder(h=o+hh+o,d=id); // hinge bore

    rotate([0,sa,0])
     translate([0,0,od])
      cylinder(h=pl,d=id); // stick bore
   }
  }
}

module bracket () {
 mfr = cw/2 - od/2; // max fillet radius that can fit
 r = (fr>mfr) ? mfr : fr ;; // fillet radius actually used
 al = cl-cw;    // adhesive length

 difference() {
  union () { // complete body without bore

   hull() { // wall plate
    cylinder(h=wt,d=cw);
    translate([0,al-cw/2,0])
     cylinder(h=wt,d=cw);
   }

   hull(){ // hinge body
    translate([-od/2,0,wt-o])
     cube([od,hh,o]); // hinge to wall plate
    translate([0,hh,po])
     rotate([90,0,0])
      cylinder(h=hh,d=od); // hinge outside
   }

   translate([od/2-o,hh,wt-o])
    rotate([90,0,0])
     fillet (r=r,l=hh); // right fillet
   translate([-od/2+o,hh,wt-o])
    rotate([0,-90,90])
     fillet (r=r,l=hh); // left fillet
  }

 translate([0,hh+wt,po])
  rotate([90,0,0])
   cylinder(h=hh,d=id); // hinge bore
 }
}

module command_strip () {
 translate([0,0,-ct/2])
  hull() {
   cube([cw,o,ct],center=true);
   translate([0,cl-cw/2,0])
    cylinder(h=ct,d=cw,center=true);
  }
}

module fillet (r=1,l=1) {
 difference() {
  cube([r,r,l]);
  translate([r,r,-o]) cylinder(h=o+l+o,r=r);
 }
}