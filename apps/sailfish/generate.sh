#!/bin/bash

# Generate graphics at different resolutions for different devices
# 1.0 (jolla phone), 1.25 (jolla c), 1.5 (tablet), 1.75 (xperia)
ratios="1.0 1.25 1.5 1.75 2.0"

# Generate app icons
sizes="86 108 128 172 256"
for size in ${sizes}; do
	mkdir -p "./icons/${size}x${size}"
	inkscape -z -e "./icons/${size}x${size}/harbour-scintillon.png" -w $size -h $size "inputs/harbour-scintillon.svg"
done

# Create the ratio directories
for ratio in ${ratios}; do
	mkdir -p "./qml/images/z${ratio}"
	mkdir -p "./qml/images/z${ratio}/archetypes"
	mkdir -p "./qml/images/z${ratio}/sensors"
done

# Function for generating PNG images
function generate {
	basex=$1
	basey=$2
	names=$3
	for ratio in ${ratios}; do
		sizex=`echo "${ratio} * ${basex}" | bc`
		sizey=`echo "${ratio} * ${basey}" | bc`
		for name in ${names}; do
			inkscape -z -e "./qml/images/z${ratio}/${name}.png" -w ${sizex} -h ${sizey} "inputs/${name}.svg"
		done
	done
}

# Function for generating archetype images
function archetype {
	basex=$1
	basey=$2
	names=$3
	for ratio in ${ratios}; do
		sizex=`echo "${ratio} * ${basex}" | bc`
		sizey=`echo "${ratio} * ${basey}" | bc`
		for name in ${names}; do
			inkscape -z -e "./qml/images/z${ratio}/archetypes/${name}.png" -w ${sizex} -h ${sizey} "inputs/archetypes/${name}.svg"
			inkscape -z -e "./qml/images/z${ratio}/archetypes/${name}-outline.png" -w ${sizex} -h ${sizey} "inputs/archetypes/${name}-outline.svg"
		done
	done
}

# Generate titles
generate 428 86 "scintillon-title"

# Generate cover action icons
generate 32 32 "icon-cover-action-off icon-cover-action-on"

# Generate small icons
generate 32 32 "icon-s-alarm icon-s-countdown cover-lights-on cover-lights-off"

# Generate medium icons
generate 64 64 "bulbGroup bulbGroup-outline bulbsSultan bulbsSultan-outline icon-m-alarm icon-m-countdown icon-m-scene icon-m-scene-outline icon-m-weekday icon-m-lights icon-m-scenes icon-m-switches icon-m-alarms icon-m-rules icon-m-bridge icon-m-rule icon-m-bright icon-m-dim"

# Archetypes
archetype 64 64 "classicbulb sultanbulb spotbulb floodbulb candlebulb huebloom hueiris huego huelightstrip hueplay groundspot bollard tablewash tableshade floorshade floorlantern flexiblelamp recessedfloor walllantern wallshade wallspot pendantround pendantlong ceilinground ceilingsquare singlespot doublespot recessedceiling"

# Sensors
generate 64 64 "sensors/tap sensors/dimmer sensors/daylight sensors/generic"

# Sensor buttons
generate 96 96 "sensors/daylight-sunrise sensors/daylight-sunset sensors/dimmer-1 sensors/dimmer-2 sensors/dimmer-3 sensors/dimmer-4 sensors/generic-0 sensors/tap-1 sensors/tap-2 sensors/tap-3 sensors/tap-4"

# Generate cover
generate 117 133 "cover-background"

