#!/usr/bin/bash

touch ${1}/${2}.sh && chmod +x ${1}/${2}.sh && echo "#!/usr/bin/bash" >>${1}/${2}.sh
