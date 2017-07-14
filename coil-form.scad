/* Parametric Coil Form
 *
 * Copyright (c) 2017  Henrik Brix Andersen <henrik@brixandersen.dk>
 * License: CC BY-SA
 */
 
// Rendering
$fn = 100;
 
module coil_comb_2d(outer_d, inner_d, shaft_d, slot_w, wire_d, slots, slot, turns, length, cutouts) {
    wire_r = wire_d / 2;
    height = (outer_d - inner_d) / 2;
    coil_length = length - slot_w * 2;
    turn_spacing = (coil_length - (turns * wire_d)) / (turns - 1);

    difference() {
        // Main outline
        hull() {
            for (i = [-1,1]) {
                translate([(length / 2 + slot_w) * i, height + 1.5 * wire_d - slot_w * 2, 0]) {
                    circle(slot_w * 2);
                }
            }
            translate([0, -1 * (inner_d - shaft_d) / 2 + 0.5, 0]) {
                #square(size = [length + slot_w * 6, 1], center = true);
            }
        }

        // Shaft cutout
        translate([0, -1 * (inner_d - shaft_d) / 2, 0]) {
            #square(size = [length, inner_d - shaft_d], center = true);
        }

        // Wire cutouts
        for (i = [0:turns - 2]) {
            offset = turn_spacing / slots * slot;
            translate([coil_length / -2 + wire_d / 2 + i * (turn_spacing + wire_d) + offset, height, 0]) {
                #circle(wire_d / 2);
            }
            translate([coil_length / -2 + i * (turn_spacing + wire_d) + offset, height, 0]) {
                #square(size = [wire_d, wire_d * 3], center = false);
            }
        }
        
        // Slot cutouts
        for (i = [-1,1]) {
            translate([length / 2 * i + i * slot_w / 2, 0, 0]) {
                #square(size = [slot_w, height], center = true);
            }
        }
        
        // Wind load reduction cutouts
        if (cutouts > 0) {
            spacing = (length - (cutouts * (height / 3 * 2))) / (cutouts + 1);
            for (i = [0:cutouts - 1]) {
                translate([length / -2 + (height / 3 * 2 * i + height / 3) + spacing * (i + 1), height / 2, 0]) {
                    #circle(height / 3);
                }
            }
        }
    }
 }
 
 module coil_comb_3d(outer_d, inner_d, shaft_d, slot_w, wire_d, slots, slot, turns, length, cutouts, thickness) {
    linear_extrude(height = thickness, center = true, convexity = 10, twist = 0) {
        coil_comb_2d(outer_d, inner_d, shaft_d, slot_w, wire_d, slots, slot, turns, length, cutouts);
    }
 }
 
module coil_retainer_2d(outer_d, inner_d, shaft_d, slot_w, wire_d, slots, dshape_h) {
    slot_depth = (outer_d - inner_d) / 4;
    
    difference() {
        // Disc outline
        circle(d=outer_d + 3 * wire_d);
        
        // Centre hole
        difference() {
            #circle(d=shaft_d);
            translate([0, (shaft_d / -2), 0]) {
                #square(size = [shaft_d, dshape_h * 2], center = true);
            }
        }
        
        // Wire hole
        rotate([0, 0, 360 / slots / 2]) {
            translate([0, shaft_d / 2 + (outer_d - shaft_d) / 4, 0]) {
                #circle(d=wire_d);
            }
        }
        
        // Slot cutouts
        for (i = [1:slots]) {
            rotate([0, 0, i * 360 / slots]) {
                translate([0, outer_d / 2, 0]) {
                    #square(size = [slot_w, slot_depth * 2], center = true);
                }
            }
        }
    }
}

module coil_retainer_3d(outer_d, inner_d, shaft_d, slot_w, wire_d, slots, dshape_h, thickness) {
    linear_extrude(height = thickness, center = true, convexity = 10, twist = 0) {
        coil_retainer_2d(outer_d, inner_d, shaft_d, slot_w, wire_d, slots, dshape_h);
    }
}

od = 50;  // Outer coil diameter
id = 25;  // Inner diameter
sd = 23;  // Shaft diameter
ds = 1;   // Shaft d-shape cut off depth
st = 3;   // Sheet thickness
wd = 1;   // Wire diameter
ct = 15;  // Coil turns
ns = 6;   // Number of slots
tl = 120; // Length between coil retainers
co = 0;   // Number of wind load reduction cutouts

wire_length = od * PI * ct;
echo(wire_length=wire_length,"mm");

//for (i = [0:5]) {
//    translate([0, i * 17, 0])
//    coil_comb_2d(od, id, sd, st, wd, ns, i, ct, tl, co);
//}
//coil_comb_3d(od, id, sd, st, wd, ns, 0, ct, tl, co, st);

coil_retainer_2d(od, id, sd, st, wd, ns, ds);
//coil_retainer_3d(od, id, sd, st, wd, ns, ds, st);
