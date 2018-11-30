// distances in mm
tooth_width = 3;
tooth_length = 2;
tooth_shape = 1.3;
desired_gear_radius = 25; // approximate! this is changed to the nearest useful value


hole_radius = 5;
th = 3;
middle_th = 3;
middle_z_offset = -1.5;

outer_wall = 2;
inner_wall = 3;

// spokes: 0-1 = solid, 2+ = spokes
spokes = 8;
spoke_thickness = 5;

// number of segments for cylinder walls
body_res = 20;
tooth_res = 10;

cutout = true;

// modules
module tooth(phi, radius, height, shape=1) {
  translate([radius*sin(phi),radius*cos(phi),0]) {
    rotate([0,0,-phi]) {
      scale([1,tooth_length/tooth_width*2,1]) {
        cylinder(h=height, r=tooth_width*shape/2, $fn=tooth_res, center=true);
      }
    }
  }
}

module gear(desired_gear_radius, th, middle_th, outer_wall, inner_wall, pos, spokes=0) {
  teeth = round(PI*desired_gear_radius/tooth_width);
  gear_radius = teeth * tooth_width / PI;
  echo("Gear Radius determined as: ", gear_radius);
  translate(pos+[0,0,th/2]) {
    difference() {
      union() {
        if (spokes <= 1) {
          // add gear body
          cylinder(h=th, r=gear_radius, $fn=body_res, center=true);
        } else {
          // add gear spokes
          difference() {
            cylinder(h=th, r=gear_radius, $fn=body_res, center=true);
            cylinder(h=th, r=gear_radius-PI*gear_radius/teeth/2-outer_wall, $fn=body_res, center=true);
          }
          for (i = [0:360/spokes:360]) {
            rotate(i) {
              translate([-spoke_thickness/2, hole_radius+inner_wall/2, -th/2]) {
                scale([spoke_thickness, gear_radius - (outer_wall/2) - (hole_radius+inner_wall/2), th]) {
                  cube(1);
                }
              }
            }
          }
        }
        
        // add outer teeth
        for (i = [180/teeth:360/teeth:360]) {
          tooth(i, gear_radius, th, 1/tooth_shape);
        }
      }
      
      // subtract central thickness
      for (i = [1, -1]) {
        translate([0,0,i*th/2+middle_z_offset]) {
          cylinder(r=gear_radius-PI*gear_radius/teeth/2-outer_wall, h=th-middle_th, $fn=body_res, center=true);
        }
      }
      if (cutout) {
        // subtract inner teeth
        for (i = [0:360/teeth:360]) {
          tooth(i, gear_radius, th, tooth_shape);
        }  
      }
      
      // subtract central hole
      cylinder(h=th+1, r=hole_radius, $fn=body_res, center=true);
    }
    difference() {
      // add central wall
      cylinder(h=th, r=hole_radius+inner_wall, $fn=body_res, center=true);
      
      // subtract central hole
      cylinder(h=th+1, r=hole_radius, $fn=body_res, center=true);
    }
  }
}
// gear(radius, max_thickness, min_thickness, outer wall, pos, spokes=0)
gear(20, th, th, 3, 3, [0,0,0], 3);
//gear(11.5, th, th, 3, 3, [0,35,0], 3);
//gear(desired_gear_radius, th, middle_th, outer_wall, inner_wall, [0,0,-th]);
//gear(47.5, th, th, 6, inner_wall, [0,0,-th], spokes);
//gear(10, 4, 4, 4, 4, [0,0,0], 6);