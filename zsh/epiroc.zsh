#!/usr/bin/zsh

alias rdkD='clear; rdk build -s rcsos-2.4.0_x86_4.4.50-rt63 -b Debug'
alias rdkDC='clear; rdk build -s rcsos-2.4.0_x86_4.4.50-rt63 -b Debug --cachepot'
alias rdkDS='clear; rdk build -s rcsos-2.4.0_x86_4.4.50-rt63 -b Debug --sccache'
alias rdkR='clear; rdk build -s rcsos-2.4.0_x86_4.4.50-rt63 -b Release'
alias rdkRC='clear; rdk build -s rcsos-2.4.0_x86_4.4.50-rt63 -b Release --cachepot'
alias rdkRS='clear; rdk build -s rcsos-2.4.0_x86_4.4.50-rt63 -b Release --sccache'

alias simst14='rdk sim start lhd ST14_70_Autonomous -n ST14_70 --sdk rcsos-2.4.0_x86_4.4.50-rt63 --keepterminals ; rdk sim start lhd OPS_1_Standard  -n ops --sdk rcsos-2.4.0_x86_4.4.50-rt63 --keepterminals ; rdk sim start lhd LhdAcMs_0_ACMS  -n  acms --sdk rcsos-2.4.0_x86_4.4.50-rt63 --keepterminal'

export PATH="$PATH:/home/max/workspace/dev/gdb-attacher/"
export PATH="$PATH:/mnt/c/Program\ Files/WezTerm/"

DEV() 
{
    # disable safety test in lhd simulator
    export RS_DISABLE_SAFETY_MONITOR=1
    # Auto login as DEV in sim (Fixed in ADS)
    export RS_DEV="DEV"
    # will disable the Disp <-> Cci communication monitor
    export RS_DISABLE_DISP_CCI_COM_MONITOR="1"
}

DEV_TEST()
{
    export SIM_ENV=1
}


NATIVE()
{
   source ../HDE/x86_64.linux/release.com
}

NATIVE_AFTER()
{
   export OSPL_HOME=/home/max/workspace/dev/HDE/x86_64.linux/
   #   export RDK_CONFIGURATION="./native_32bit_configuration.yaml"
   export RDK_USE_NAMESPACE=false
}

AOPS()
{
   ##########################
   # DDS settings RCSOS 2.4 #
   ##########################
   OSPL_HOME="/opt/sdks/rcsos-2.4.0/x86_4.4.50-rt63/sysroots/x86-rcs-linux/usr/ospl" 
   source $OSPL_HOME/release.com
   OSPL_URI="file:///opt/sdks/rcsos-2.4.0/x86_4.4.50-rt63/sysroots/x86-rcs-linux/usr/ospl/etc/config/ospl_shmem_no_network.xml"
}

AOPS3()
{
   ############################
   # DDS settings RCSOS 3.3.0 #
   ############################
   OSPL_HOME="/opt/sdks/rcsos-3.3.0/x86_4.19.180-rt73/sysroots/x86-rcsos-linux/usr/ospl"
   source $OSPL_HOME/release.com
   OSPL_URI="file:///opt/sdks/rcsos-3.3.0/x86_4.19.180-rt73/sysroots/x86-rcsos-linux/usr/ospl/etc/config/ospl_shmem_no_network.xml"
}

deploy()
{
   device="ST14_70_Autonomous"
   if [ ${(L)1} = "st18" ]; then
      device="ST18_32_ARV_NO_RRC"
   elif [ ${(L)1} = "mt42" ]; then
      device="MT42_Autonomous_Stage_4"
   elif [ ${(L)1} = "ops1" ]; then
      device="OPS_1_Standard"
      elif [ ${(L)1} = "ops2" ]; then
         device="OPS_3_StandardGen2"
   elif [ ${(L)1} = "acms" ]; then
      device="LhdAcMs_0_ACMS"
   fi
   rdk deploy lhd $device --pkg -b Release --lab
}
