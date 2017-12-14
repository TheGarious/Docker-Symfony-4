#/bin/bash

export PROJECT_NAME="project"
export DOCKER_NAME="$PROJECT_NAME"
#export CONTAINER_PATH="$(readlink -f $(dirname $0))"
export CONTAINER_PATH="./" # for mac readlink not exist
export PROJECT_PATH="$CONTAINER_PATH/projects"
export PROJECTS=`ls $PROJECT_PATH`

export DOCKER_IS_INSTALL=`which docker | wc -l`

export HTTP_PORT="80"
export HTTPS_PORT="443"
export ELK_PORT="8081"
export PHPMYADMIN_PORT="8082"
export MAILHOG_PORT="8083"
export MYSQL_PORT="3306"

export USERID=1000

if [ $DOCKER_IS_INSTALL == "0" ]; then
	echo "Error: docker not found. You must be install docker."
	echo "You can run:"
	echo "    curl -fsSL https://get.docker.com/ | sh"
	echo "    sudo sh -c 'sudo -- curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose'"
	echo "    sudo chmod +x /usr/local/bin/docker-compose"
	echo "    sudo usermod -aG docker $USER"
	echo "    sudo service docker start"
	echo "    # reload session after'"
	exit
fi

function build {
	HELP=0
	while [[ $# > 0 ]]; do
		key="$1"
		case $key in
			-h|--help)
				HELP=1
		;;
		esac
		shift
	done
	if [ "$HELP" == "1" ]; then
		echo -e "\033[0;33mUsage:\033[0m"
		echo -e "    docker.sh build"
		exit
	fi;

	touch $CONTAINER_PATH/.bash_history 2> /dev/null

	echo "" > $CONTAINER_PATH/containers/nginx/projects.conf
	for PROJECT in $PROJECTS; do
		cat $CONTAINER_PATH/containers/nginx/projects.conf.dist | sed -e "s/\${PROJECT}/$PROJECT/" >> $CONTAINER_PATH/containers/nginx/projects.conf
	done

	echo -e "\033[0;33m"
        echo -e "=========================="
        echo -e "= Docker build container ="
        echo -e "=========================="
        echo -e "\033[0m"

	COMMAND="docker-compose build"
	echo "exec: $COMMAND"
	$COMMAND

}

function start {
	HELP=0
	while [[ $# > 0 ]]; do
		key="$1"
		case $key in
			-h|--help)
				HELP=1
			;;
			-p|--http-port)
				shift
				if [ "$1" != "" ]; then export HTTP_PORT="$1"; fi
			;;
			--https-port)
				shift
				if [ "$1" != "" ]; then export HTTPS_PORT="$1"; fi
			;;
			--elk-port)
				shift
				if [ "$1" != "" ]; then export ELK_PORT="$1"; fi
			;;
			--phpmyadmin-port)
				shift
				if [ "$1" != "" ]; then export PHPMYADMIN_PORT="$1"; fi
			;;
			--mailhog-port)
				shift
				if [ "$1" != "" ]; then export MAILHOG_PORT="$1"; fi
			;;
			-m|--mysql-port)
				shift
				if [ "$1" != "" ]; then export MYSQL_PORT="$1"; fi
			;;
			*)
				echo "Parameter $key not exist."
				exit
			;;
		esac
		shift
	done

	if [ "$HELP" == "1" ]; then
		echo -e "\033[0;33mUsage:\033[0m"
		echo -e "    docker.sh start [<parameter>...]"
		echo -e ""
		echo -e "\033[0;33mParameters:\033[0m"
		echo -e "    \033[0;32m-h, --help\033[0m         Display more informations on the <command>"
		echo -e "    \033[0;32m-p, --http-port\033[0m    Set HTTP port for apache servcer. The port is 80 by default"
		echo -e "    \033[0;32m-m, --mysql-port\033[0m   Set MYSQL port for apache servcer. The port is 3306 by default"
		echo -e "    \033[0;32m--https-port\033[0m       Set HTTPS port for apache servcer. The port is 443 by default"
		echo -e "    \033[0;32m--phpmyadmin-port\033[0m  Set PhpMyAdmin port for apache servcer. The port is 8082 by default"
		echo -e "    \033[0;32m--mailhog-port\033[0m     Set MailHog port for apache servcer. The port is 8083 by default"
		echo -e "    \033[0;32m--elk-port\033[0m         Set ELK port for apache servcer. The port is 8081 by default"
		exit
	fi;

	COMMAND="docker-compose -p $DOCKER_NAME -f docker-compose.yml up -d"
	echo "exec: $COMMAND"
	$COMMAND

	sleep 1

	DISPLAY_HTTP_PORT=":$HTTP_PORT"
	DISPLAY_HTTPS_PORT=":$HTTPS_PORT"
	if [ "$HTTP_PORT"  = "80"  ]; then DISPLAY_HTTP_PORT=""  ;fi
	if [ "$HTTPS_PORT" = "443" ]; then DISPLAY_HTTPS_PORT="" ;fi

	echo -e "\033[0;33m"
	echo -e "================"
	echo -e "= Docker start ="
	echo -e "================"
	echo -e "\033[0m"
	echo -e "Local http port: $HTTP_PORT"
	echo -e "Local https port: $HTTPS_PORT"
	echo -e "Local MySQL port: $MYSQL_PORT"
	echo -e ""
	echo -e "PHPMyAdmin HTTP:  \033[0;32mhttp://127.0.0.1:$PHPMYADMIN_PORT/\033[0m"
	echo -e "MailHog HTTP:     \033[0;32mhttp://127.0.0.1:$MAILHOG_PORT/\033[0m"
	echo -e "ELK HTTP:         \033[0;32mhttp://127.0.0.1:$ELK_PORT/\033[0m"
	echo -e ""
	for PROJECT in $PROJECTS; do
		#echo -e "$PROJECT HTTP:	\033[0;32mhttp://$PROJECT$DISPLAY_HTTP_PORT/\033[0m"
		echo -e "$PROJECT HTTPS:	\033[0;32mhttps://$PROJECT$DISPLAY_HTTPS_PORT/\033[0m"
	done
	echo -e ""
}

function stop {
	HELP=0
	while [[ $# > 0 ]]; do
		key="$1"
		case $key in
			-h|--help)
				HELP=1
		;;
		esac
		shift
	done
	if [ "$HELP" == "1" ]; then
		echo -e "\033[0;33mUsage:\033[0m"
		echo -e "    docker.sh stop"
		exit
	fi;

	echo -e "\033[0;33m"
        echo -e "==========================="
        echo -e "= Docker stop all service ="
        echo -e "==========================="
        echo -e "\033[0m"

	IDS=`docker ps -a -q`
	if [ "$IDS" != "" ]; then
		COMMAND="docker rm -f $IDS"
		echo "exec: $COMMAND"
		$COMMAND
	fi;
}

function list {
	HELP=0
	while [[ $# > 0 ]]; do
		key="$1"
		case $key in
			-h|--help)
				HELP=1
		;;
		esac
		shift
	done
	if [ "$HELP" == "1" ]; then
		echo -e "\033[0;33mUsage:\033[0m"
		echo -e "    docker.sh list"
		exit
	fi;

	echo -e "\033[0;33m"
        echo -e "============================="
        echo -e "= Docker list all container ="
        echo -e "============================="
        echo -e "\033[0m"

		COMMAND="docker ps -a"
		echo "exec: $COMMAND"
		$COMMAND
}

function connect {
	HELP=0
	while [[ $# > 0 ]]; do
		key="$1"
		case $key in
			-h|--help)
				HELP=1
		;;
		esac
		shift
	done
	if [ "$HELP" == "1" ]; then
		echo -e "\033[0;33mUsage:\033[0m"
		echo -e "    docker.sh connect"
		exit
	fi;

	echo -e "\033[0;33m"
        echo -e "=========================="
        echo -e "= Docker connect console ="
        echo -e "=========================="
        echo -e "\033[0m"

	COMMAND="docker exec -u dev -it "$DOCKER_NAME"_php_1 /bin/bash"
	echo "exec: $COMMAND"
	$COMMAND
}

function clean_none {
	HELP=0
	while [[ $# > 0 ]]; do
		key="$1"
		case $key in
			-h|--help)
				HELP=1
		;;
		esac
		shift
	done
	if [ "$HELP" == "1" ]; then
		echo -e "\033[0;33mUsage:\033[0m"
		echo -e "    docker.sh clean-none"
		exit
	fi;
	
	echo -e "\033[0;33m"
        echo -e "============================"
        echo -e "= Docker clean none images ="
        echo -e "============================"
        echo -e "\033[0m"
	
	COMMAND="docker rmi $(docker images | grep "^<none>" | awk "{print $3}")"
	echo "exec: $COMMAND"
	$COMMAND
}

function remove {
	HELP=0
	while [[ $# > 0 ]]; do
		key="$1"
		case $key in
			-h|--help)
				HELP=1
		;;
		esac
		shift
	done
	if [ "$HELP" == "1" ]; then
		echo -e "\033[0;33mUsage:\033[0m"
		echo -e "    docker.sh remove"
		exit
	fi;
	
	echo -e "\033[0;33m"
        echo -e "========================"
        echo -e "= Docker remove images ="
        echo -e "========================"
        echo -e "\033[0m"
	
	COMMAND="docker rmi `docker images | cut -d" " -f1 | grep $DOCKER_NAME`"
	echo "exec: $COMMAND"
	$COMMAND
}

COMMAND="$1"
shift
case $COMMAND in
	start)
		start $@
	;;
	stop)
		stop $@
	;;
	connect)
		connect $@
	;;
	build)
		build $@
	;;
	list)
		list $@
	;;
	clean-none)
		clean_none $@
	;;
	remove)
		remove $@
	;;
	*)
		echo -e ""
		echo -e "\033[0;31mError <command> not found or not valid\033[0m"
		echo -e ""
		echo -e "\033[0;33mUsage:\033[0m"
		echo -e "    docker.sh <command> [<parameter>...]"
		echo -e ""
		echo -e "\033[0;33mCommand:\033[0m"
		echo -e "    \033[0;32mbuild\033[0m       Re-build docker container"
		echo -e "    \033[0;32mconnect\033[0m     Connect to the console of docker container"
		echo -e "    \033[0;32mlist\033[0m        List all container enable"
		echo -e "    \033[0;32mstart\033[0m       Start docker service"
		echo -e "    \033[0;32mstop\033[0m        Stop docker service"
		echo -e "    \033[0;32mclean-none\033[0m  Remove unammed image"
		echo -e "    \033[0;32mremove\033[0m      Remove $DOCKER_NAME image"
		echo -e "\033[0;33mParameters:\033[0m"
		echo -e "    \033[0;32m-h, --help\033[0m  Display more informations on the <command>"
		echo -e ""
	;;
esac
