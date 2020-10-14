#!/bin/bash
#
#       launch_step2-2_make_stats_on_tag.sh
#
#       Copyright 2020 Sylvain Marthey <sylvain.marthey@inrae.fr>
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 3 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, see <http://www.gnu.org/licenses/>.

# load project configuration
source config.txt

sbatch \
-J tag_stats \
-o ${UMI_tagged}/step2-2_make_stats_on_tag.out \
-e ${UMI_tagged}/step2-2_make_stats_on_tag.err \
--mem=8G \
--mail-type=FAIL \
step2-2_make_stats_on_tag.sh
