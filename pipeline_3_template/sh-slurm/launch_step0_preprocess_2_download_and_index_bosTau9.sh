#!/bin/bash
#
#       launch_step0_preprocess_2_download_and_index_bosTau9.sh
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

mkdir ${project_path}/index

sbatch \
-J dl_index \
-o ${project_path}/index/step0_preprocess_2_download_and_index_bosTau9.sh.out \
-e ${project_path}/index/step0_preprocess_2_download_and_index_bosTau9.sh.err \
-t 8:00:00 \
--mem=16G \
--mail-type=FAIL \
step0_preprocess_2_download_and_index_bosTau9.sh