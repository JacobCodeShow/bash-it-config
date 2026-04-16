function ci () {
		local dir=`pwd | awk -F/ '{print $NF}'`
		local prefix=`pwd | sed "s/$dir//"`
		export SYSREPO_TOKEN=bg9RfDrGDGQUWm2-WsF5
		export WORKSPACE=$prefix
		export UNIT_TEST_PKG=$dir
		#setproxy
		cd $WORKSPACE
		./openbmc-build-scripts/run-unit-test-docker.sh
		cd -
}

