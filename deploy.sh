#!/bin/bash

###
# DEFAULT VALUES
###

MODE_HELP="defines how the logstash-modsecurity configuration should be deployed (has to be one off 'symlink', 'file')"
MODE="symlink"

TARGET_HELP="defines, where the logstash-modsecurity config should be deployed 
           For MODE='symlink' TARGET is expected to be a directory (where the symlink to the source files are created)
           For MODE='file' TARGET is expected to be a file (resulting file of concat operation of all source files)
           If TARGET does not exists, it will be created."
TARGET="/etc/logstash/conf.d"

SOURCEDIR_HELP="defines, where the logstash-modsecurity config is found, this should point to the directory, where the git clone of logstash-modsecurity is placed."
SOURCEDIR=""

MODULES_HELP="contains the selected rule ids, which should be deployed"
declare -a MODULES=(
	"0000_header.conf"
	"1000_input_stdin_example.conf"
#	"1010_input_file_example.conf"
	"2000_filter_sections_split.conf"
	"2010_filter_section_a_parse.conf"
	"2020_filter_section_b_parse_request_line.conf"
	"2021_filter_section_b_headers_key-value.conf"
#	"2029_filter_section_b_example_header_Cookie.conf"
#	"2029_filter_section_b_example_header_X-Forwarded-For.conf"
#	"2029_filter_section_b_example_splitt_all_cockies.conf"
	"2030_filter_section_c_parse.conf"
#	"2040_filter_section_d_example.conf"
#	"2050_filter_section_e_example.conf"
	"2060_filter_section_f_parse_request_line.conf"
	"2061_filter_section_f_parse_headers.conf"
	"2062_filter_section_f_headers_key-value.conf"
#	"2070_filter_section_g_example.conf"
	"2080_filter_section_h_parse_messages_to_auditLogTrailerMessages.conf"
	"2081_filter_section_h_convert_to_key-value.conf"
	"2082_filter_section_h_extract_stopwatch.conf"
#	"2089_filter_section_h_example_geoip.conf"
#	"2089_filter_section_h_example_severities.conf"
#	"2090_filter_section_i_example.conf"
#	"2100_filter_section_j_example.conf"
	"2110_filter_section_k_parse_matchedRules.conf"
	"2500_filter_cleanup.conf"
	"3000_output_stdout_example.conf"
)

###
# END DEFAULT VALUES
###

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	echo "Usage: $0 [-h | --help] [config-file]"
	echo "  -h, --help : print usage"
	echo
	echo "MODE       ${MODE_HELP}"
        echo "TARGET     ${TARGET_HELP}"
        echo "SOURCEDIR  ${SOURCEDIR_HELP}"
        echo "MODULES    ${MODULES_HELP}"
	echo
	echo "For an example config file see logstash-modsecurity.cfg.example"
	echo
	echo "Without config-file, default settings are used"
	echo "MODE:      ${MODE}"
	echo "TARGET:    ${TARGET}"
	echo "SOURCEDIR: ${SOURCEDIR}"
	echo "MODULES:"
	for MODULE in "${MODULES[@]}"
	do
        	echo "* ${MODULE}"
	done
	echo
	exit 0
fi

# Source config in /etc
if [[ -r /etc/logstash-modsecurity.conf ]]; then
	echo "Source config from /etc/logstash-modsecurity.cfg"
	source /etc/logstash-modsecurity.conf
fi

# Source config in argument $1 if present
if [[ -n "$1" ]]; then
	if [[ -r "$1" ]]; then
		echo "Source config from $1"
		source $1
	else 
		echo "ERROR: Unable to read config file: $1"
		exit 1
	fi
fi

# Validate MODE and TARGET
if [[ "${MODE}" == "symlink" || "${MODE}" == "file" ]]; then
	if [[ "${MODE}" == "symlink" ]]; then
		if [[ ! -e "${TARGET}" ]]; then
			echo "Create directory: ${TARGET}"
			mkdir -p ${TARGET}
			if [[ "$?" -ne "0" ]]; then
				echo "ERROR: Unable to create ${TARGET}"
				exit 1
			fi
		else 
			if [[ ! -d "${TARGET}" ]]; then
				echo "ERROR: MODE is 'symlink' but TARGET is not a directory, TARGET is ${TAGET}"
				exit 1
			fi
		fi
	else
		# MODE == "file"
		if [[ ! -e "${TARGET}" ]]; then
			TARGETDIR=`dirname ${TARGET}`
			if [[ ! -d "${TARGETDIR}" ]]; then
				echo "Create target directory: ${TARGETDIR}"
				mkdir -p ${TARGETDIR}
				if [[ "$?" -ne "0" ]]; then
					echo "ERROR: Unable to create ${TARGETDIR}"
					exit 1
				fi
				touch ${TARGET}
				if [[ "$?" -ne "0" ]]; then
					echo "ERROR: Unable to create ${TARGET}"
					exit 1
				fi
			fi
		else 
			if [[ ! -w "${TARGET}" || ! -f "${TARGET}" ]]; then
				echo "ERROR: MODE is 'file', TARGET exists, but is not a writeable file, TARGET is ${TARGET}"
				exit 1
			else
				>${TARGET}
			fi
		fi
	fi
else
	echo "ERROR: MODE is expected to by one of 'symlink' or 'file', MODE is ${MODE}"
	exit 1
fi

# Get SOURCEDIR from script location, if not specified
if [[ -z "${SOURCEDIR}" ]]; then
	pushd `dirname $0` > /dev/null
	SOURCEDIR=`pwd -P`
	popd > /dev/null
else
	if [[ ! -d "${SOURCEDIR}" ]]; then
		echo "ERROR: SOURCEDIR is not a directory."
		exit 1
	fi
fi

# Print current settings
echo "MODE: ${MODE}"
echo "TARGET: ${TARGET}"
echo "SOURCEDIR: ${SOURCEDIR}"
echo

for FILE in "${MODULES[@]}"
do
	echo "process ${FILE}"
	if [[ ! -r "${SOURCEDIR}/${FILE}" ]]; then
		echo "ERROR: Unable to read ${SOURCEDIR}/${FILE}"
	fi

	if [[ "$MODE" == "symlink" ]]; then
		ln -s ${SOURCEDIR}/${FILE} ${TARGET}/${FILE}
		if [[ "$?" -ne "0" ]]; then
			echo "ERROR: Unable to create symlink ${TARGET}/${FILE}"
		fi
	else
		# MODE == "file"
		cat ${SOURCEDIR}/${FILE} >> ${TARGET}
		if [[ "$?" -ne "0" ]]; then
			echo "ERROR: Unable to concat ${SOURCEDIR}/${FILE} to ${TARGET}/${FILE}"
		fi
	fi
done
