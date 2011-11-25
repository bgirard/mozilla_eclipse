#!/bin/bash

DEFAULT_PROJECT_NAME=mozilla-central

function error {
  echo "error:" $1
  exit -1
}

echo "To generate the project settings please enter the following."
echo ""
echo -n "Mozilla top level source directory: "
read MOZ_SRC_DIR

if [[ ! -d "$MOZ_SRC_DIR" ]];
then
  error "$MOZ_SRC_DIR is not a directory."
fi

# Sanity check
if [[ ! -f "$MOZ_SRC_DIR/configure.in" ]];
then
  error "$MOZ_SRC_DIR/configure.in not found, this must not be the top level source directory."
fi

echo -n "Mozilla object directory: "
read MOZ_OBJ_DIR

MOZ_DIST_INCLUDE=$MOZ_OBJ_DIR/dist/include/mozilla-config.h

if [[ ! -d "$MOZ_OBJ_DIR" ]];
then
  error "$MOZ_OBJ_DIR is not a directory."
fi

if [[ ! -f "$MOZ_DIST_INCLUDE" ]];
then
  error "$MOZ_DIST_INCLUDE not found, this must not be the objdir directory."
fi

echo -n "Enter your eclipse project name [$DEFAULT_PROJECT_NAME]: "
read PROJECT_NAME
if [ -z $PROJECT_NAME ]
then
  PROJECT_NAME=$DEFAULT_PROJECT_NAME
fi

echo $PROJECT_NAME

PROJECT_SETTINGS_IN=`cat settings.xml.in`
PROJECT_DEFINES=`cat $MOZ_DIST_INCLUDE | grep -i "#define" | awk '{ print "<macro><name>" $2 "</name><value>true</value></macro>" }'`

PROJECT_SETTINGS_IN=${PROJECT_SETTINGS_IN/\$SETTINGS_INCLUDE_FILE/$MOZ_OBJ_DIR\/dist\/include}
PROJECT_SETTINGS_IN=${PROJECT_SETTINGS_IN/\$SETTINGS_DEFINE/$PROJECT_DEFINES}

echo "$PROJECT_SETTINGS_IN" > settings.xml

echo "Written config file to settings.xml. Import from eclipse."
echo "Project settings -> C/C++ General -> Path and Symbols -> Import Settings..."
