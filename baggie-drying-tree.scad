// reclosable baggie drain & dry hanger
// Brian K. White - b.kenyon.w@gmail.com
//
// Uses chopsticks or skewers for the hangers and the hinge.
// Supports 6mm round or 5mm round chopsticks, or even 3mm round skewers
//
// print 2 bracket() and however many arm() you want
// print_kit() prints 2 bracket() and 6 arm()
//
// bracket() are sized for Command(tm) refill size Small
//
// printing notes:
// * initial layer expansion -0.2  (counteract elephant's foot)
// * The swing arm parts have very little contact patch with the bed, and need help staying in place.
//   Normally you would use a brim, but for this it's useful to keep the bottom edges clean.
//   You can avoid using a brim by using overhang support instead:
//     style concentric, 2 walls (you don't need 2 walls for the strength, you need it for the bed contact area)
//     overhang angle 40  (the part is exactly 45 degrees, and is a cylinder where most of the surface is curved up from there, 40 yeilds a fat wall down the center of the cylinder about 2/3 as wide)
//     touching build plate only  (you don't want support inside any of the bore holes)
//     top Z seperation 0.2mm
//     Z overrides XY
// * The top few layers are small and need more time to solidify before the next layer.
//   Set minimum layer time to at least 10 seconds.
//
// post-print:
// * may need to ream out the bottom inside edge of the vertical bore a little to remove a little interior elephant's foot constricting the hole at the bottom surface.

// TODO & ideas
// * Variant with one-piece hinge bracket. Bores open all the way through top & bottom, bottom hole is smaller. You insert a full stick from the top, pointed end down. Less flexible, but much simpler installation.
// * baked-in bed adhesion structure for the arm part instead of relying on user slicer settings.
// * support rectangular sticks

///////////////////////////////////////////////////////////////////////////
//  OUTPUT
///////////////////////////////////////////////////////////////////////////

if (part == "kit") print_kit();
else if (part == "arm") arm();
else if (part == "bracket") bracket();
else {
 print_kit();  // export all the parts for a kit, arranged for printing
 translate([pl*2,(od+s)*ns,cw/2]) %assembly(); // display all the parts assembled
 //arm();  // export just an arm
 //bracket();  // export just a bracket
}

///////////////////////////////////////////////////////////////////////////

// this is used by Makefile to generate different STL's
part = "";

// stick diameter - Usually 6, 5, or 3. Chopsticks: 6 or 5  Skewers: 3 - If the sticks are too tight, first look for elephant's foot around the bottom of the vertical bore, scrape it out with xacto knife.
sd = 6;

// number of sticks
ns = 6;

// wall thickness - around the bores, also wall plate thickness
wt = 1;

// fitment clearance - Adjust this if the sticks are too tight or too loose. Set this so that the sticks fit very snugly into the swing arms, and don't quite fit into the hinge end caps. The end caps will always be too tight because of the unsupported overhang inside the pocket. For the hinge, cut or sand a small flat into each end of the stick.
fc = 0.2;

// stick angle - 30 to 60
sa = 45;

// fillet radius - where the hinge meets the wall plate
fr = 2;

// void seperation - seperate the corners of the angled bore from the floor and the vertical bore
vs = 0.4;

// Command(tm) strip refills, size small
//https://www.command.com/3M/en_US/command/products/~/Command-Clear-Small-Refill-Strips/?N=5924736+3294529207+3294737336
//https://www.command.com/3M/en_US/command/products/~/Command-Outdoor-Small-Refill-Strips/?N=5924736+3293833403+3294529207

// Command(tm) strip width - small=15 med & large=19
cw = 16;
// Command(tm) strip length - small=46 med=70 large=95
cl = 46;
ct = 0.3+0; // Command(tm) strip thickness

s = 1+0; // part seperation on print bed
o = 0.01+0; // union/difference overlap/overhang
$fn = 72+0; // arc smoothness


////////////////////////////////////////////////////////////////////////////////
// calculated/derived values

id = fc+sd+fc; // id of stick bores
od = wt+id+wt; // od around stick bores
//pl = sd*3; // pocket length - length of stick holder tube

// right-triangles derived from outside diameter and stick angle

// right-triangle for top part of hh and some other things
// c=od, alpha=sa -> find "a" for top half of hh
a_od = od*sin(sa); // side "a" (vertical) for od, for top part of hh
b_od = sqrt(od*od-a_od*a_od); // side "b" (horizontal) for od
h_od = (a_od*b_od)/od; // hypotenuse for od used a few places later

// complimentary right-triangle for bottom part of hh
// b=b_od, beta=sa -> find "a" (vertical) for bottom half of hh
c_od_comp = b_od/sin(sa);
a_od_comp = sqrt(c_od_comp*c_od_comp-b_od*b_od); // side "a" for bottom part of hh
// finally, the hinge height - arms stack vertically regardless what angle
hh = a_od+a_od_comp+fc;

//pl_min = hh/cos(sa);
//pl_opt = sd*3;
//pl = (pl_min>pl_opt) ? pl_min : pl_opt;
pl = sd*3;

// right-triangle derived from inside diameter and stick angle
// c=id, alpha=sa, -> find a & b
a_id = id*sin(sa); // side "a" (vertical) for the arm pocket id
b_id = sqrt(id*id-a_id*a_id); 


po_min = od/2+wt+fc; // minimum pin offset - hinge center to wall surface
// extra pin offset - Extra space between the wall and the hinge. You might want this if you put some kind of knob or T on the ends of the sticks, you can use this to bring the hinge pin out away from the wall to make the sticks parallel with the wall again.
po_extra = 0;
po = po_min+po_extra;


module print_kit () {
 y = od+s; // arm spacing
 bx = pl+od+cw/2; // brackets x offset
 
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


// translate the angled cylinders after rotating
arm_xo = id/2+b_id/2+vs;
arm_zo = a_id/2+vs;

// lengthen the before-cut angled OD cyl
// and lower by the same amount before rotating
// so that the outer cylinder projects below Y=0
// to give more bed adhesion area for printing, and a neater appearance
arm_co = sqrt(arm_zo*arm_zo+arm_xo*arm_xo);

// when re-adding the top part of the angled OD cyl after cutting,
// shorten the cyl and elevate by the sam amount before rotating,
// so none of the final angled cyl projects below Y=0.
// Needs to scale with sa or a_od.
// As the angle increases, the bottom of the cyl needs to move
// further out to stay above Y=0.
// But also the top of the bottom end of the cyl must stay below Y=hh.
aos = a_od*((wt*2)/od);

module arm () {
  difference() {
   union() {
    difference() {
     union() {
      hull() {
       translate([0,0,-o])
        cylinder(h=hh+a_od,d=od); // hinge od before cut
      translate([arm_xo,0,arm_zo])
       rotate([0,sa,0])
        translate([0,0,-arm_co])
         cylinder(h=pl+arm_co,d=od); // arm od before cut
      }
     }

     group () {
      translate([-(o+od+o)/2,-(o+od+o)/2,-od])
       cube([od*2,o+od+o,od]); // arm bottom cut
      translate([-(o+od+o)/2,-(o+od+o)/2,hh])
       cube([pl+od+1,o+od+o,od]); // arm top cut
     }
    }

    translate([arm_xo,0,arm_zo])
     rotate([0,sa,0])
      translate([0,0,aos])
       cylinder(h=pl-aos,d=od); // arm od after cut
   }

   group() {
    translate([0,0,-o])
     cylinder(h=o+hh+o,d=id); // hinge bore
    translate([arm_xo,0,arm_zo])
     rotate([0,sa,0])
      cylinder(h=pl+o,d=id); // stick bore
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