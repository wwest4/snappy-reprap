include <config.scad>
use <GDMUtils.scad>
use <joiners.scad>
use <publicDomainGearV1.1.scad>


module slider_sled()
{
	union() {
		difference() {
			union() {
				// Bottom
				translate([0,0,platform_thick/2])
					yrot(90) sparse_strut(h=platform_width, l=platform_length, thick=platform_thick, maxang=45, strut=12, max_bridge=999);

				// Walls.
				zrot_copies([0, 180]) {
					translate([(platform_width-joiner_width)/2, 0, platform_height/2]) {
						if (wall_style == "crossbeams")
							sparse_strut(h=platform_height, l=platform_length-10, thick=joiner_width, strut=5);
						if (wall_style == "thinwall")
							thinning_wall(h=platform_height, l=platform_length-10, thick=joiner_width, strut=platform_thick, wall=3, bracing=false);
						if (wall_style == "corrugated")
							corrugated_wall(h=platform_height, l=platform_length-10, thick=joiner_width, strut=platform_thick, wall=3);
					}
				}
			}

			// Clear space for joiners.
			translate([0,0,platform_height/2]) {
				joiner_quad_clear(xspacing=platform_width-joiner_width, yspacing=platform_length, h=platform_height, w=joiner_width, clearance=5, a=joiner_angle);
			}
		}

		// Snap-tab joiners.
		translate([0,0,platform_height/2]) {
			joiner_quad(xspacing=platform_width-joiner_width, yspacing=platform_length, h=platform_height, w=joiner_width, l=5, a=joiner_angle);
		}

		// sliders
		mirror_copy([1,0,0]) {
			translate([-(rail_spacing)/2, 0, 0]) {
				// bottom strut
				translate([6/2,0,rail_offset/2]) {
					difference() {
						cube(size=[6, platform_length, rail_offset], center=true);
						grid_of(
							ya=[-(platform_length/2), (platform_length/2)],
							za=[groove_height/2]
						) {
							xrot(45) cube(size=[11, 2*sqrt(2), 2*sqrt(2)], center=true);
						}
						grid_of(
							ya=[-(platform_length/2), (platform_length/2)],
							xa=[-6/2]
						) {
							zrot(45) cube(size=[2*sqrt(2), 2*sqrt(2), rail_offset+1], center=true);
						}
					}
				}

				grid_of(
					ya=[-platform_length*6/16, 0, platform_length*6/16],
					za=[rail_offset+groove_height/2]
				) {
					// Slider base
					translate([10/2-4, 0, -groove_height]) {
						difference() {
							cube(size=[10, platform_length/8, groove_height], center=true);
							grid_of(
								ya=[-(platform_length/8/2), (platform_length/8/2)],
								za=[groove_height/2]
							) {
								xrot(45) cube(size=[11, 2*sqrt(2), 2*sqrt(2)], center=true);
							}
						}
					}

					// Slider backing
					translate([6/2, 0, 0]) {
						difference() {
							cube(size=[6, platform_length/8, groove_height], center=true);
							grid_of(
								ya=[-(platform_length/8/2), (platform_length/8/2)],
								za=[groove_height/2]
							) {
								xrot(45) cube(size=[11, 2*sqrt(2), 2*sqrt(2)], center=true);
							}
						}
					}

					// Slider ridge
					scale([tan(groove_angle),1,1]) {
						yrot(45) {
							chamfcube(size=[groove_height/sqrt(2), platform_length/8, groove_height/sqrt(2)], chamfer=2, chamfaxes=[1,0,1], center=true);
						}
					}
				}
			}
		}
	}
}
//!slider_sled();



module herringbone_rack(l=100, h=10, w=10, tooth_size=5, CA=30)
{
	translate([-(rack_tooth_size/2), 0, 0]) {
		mirror_copy([0,0,1]) {
			skew_along_z(xang=CA) {
				intersection() {
					translate([-(l/2-rack_tooth_size/2), 0, h/4]) {
						rack(
							mm_per_tooth=rack_tooth_size,
							number_of_teeth=floor(l/rack_tooth_size),
							thickness=h/2,
							height=w,
							pressure_angle=20,
							backlash=0
						);
					}
					cube(size=[l, h*3, h*3], center=true);
				} 
			}
		}
	}
}
//!herringbone_rack(l=100, h=10, tooth_size=5, CA=30);



module sled()
{
	color("MediumSlateBlue")
	prerender(convexity=10)
	union() {
		// Base slider sled.
		slider_sled();

		// Length-wise bracing.
		translate([0,0,platform_thick/2]) {
			translate([-10, 0, 1])
				cube(size=[14,platform_length,platform_thick+2], center=true);
		}

		// Drive rack
		translate([-8, 0, platform_thick+2+5]) {
			zrot(-90) herringbone_rack(l=platform_length, h=10, tooth_size=rack_tooth_size, CA=30);
		}
	}
}



module sled_parts() { // make me
	zrot(90) sled();
}


sled_parts();


// vim: noexpandtab tabstop=4 shiftwidth=4 softtabstop=4 nowrap

