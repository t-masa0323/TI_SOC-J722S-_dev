# This environment variable is used to select the appropriate board in the name
# of the linux boot and root partitions for scripts in this directory.
# This sets default, but could be overwritten from environment variable.
: "${TI_DEV_BOARD:=j722s-evm}"
: "${SOC:=j722s}"
: "${TISDK_IMAGE:=adas}"
