CLASS := PluginExample
OUT := godot_example

SCHEME := godot_plugin
PROJECT := godot_plugin.xcodeproj
GODOT := 4.2.1-stable
GODOT_SRC := https://github.com/godotengine/godot.git
SCONS := scons
ARCHIVE_FLAGS = -quiet -project ./${PROJECT} -scheme ${SCHEME} SKIP_INSTALL=NO GCC_PREPROCESSOR_DEFINITIONS="DEBUG_ENABLED=${1} PluginClass=${CLASS}" "OTHER_CPLUSPLUSFLAGS=-std=c++17 -Igodot/platform/ios" "OTHER_SWIFT_FLAGS=${SWIFT_FLAGS}"
ARCHIVE_ARGS = -archivePath ./bin/${1}_${2}.xcarchive -sdk ${3} -arch ${4}
xcarchive_out = bin/${1}_${2}.xcarchive/Products/usr/local/lib/${OUT}.a
xcframework_out = bin/${OUT}.${1}.xcframework

all: debug release
debug: $(call xcframework_out,debug)
release: $(call xcframework_out,release)

$(call xcarchive_out,ios,debug): bin godot_plugin/*
	xcodebuild archive $(call ARCHIVE_ARGS,ios,debug,iphoneos,arm64) -configuration Debug $(call ARCHIVE_FLAGS,1)
	mv $(@:${OUT}.a=lib${SCHEME}.a) $@

$(call xcarchive_out,sim,debug): bin godot_plugin/*
	xcodebuild archive $(call ARCHIVE_ARGS,sim,debug,iphonesimulator,x86_64) -configuration Debug $(call ARCHIVE_FLAGS,1)
	mv $(@:${OUT}.a=lib${SCHEME}.a) $@

$(call xcarchive_out,ios,release): bin godot_plugin/*
	xcodebuild archive $(call ARCHIVE_ARGS,ios,release,iphoneos,arm64) $(call ARCHIVE_FLAGS,0)
	mv $(@:${OUT}.a=lib${SCHEME}.a) $@

$(call xcarchive_out,sim,release): bin godot_plugin/*
	xcodebuild archive $(call ARCHIVE_ARGS,sim,release,iphonesimulator,x86_64) $(call ARCHIVE_FLAGS,0)
	mv $(@:${OUT}.a=lib${SCHEME}.a) $@

$(call xcframework_out,debug): $(call xcarchive_out,ios,debug) $(call xcarchive_out,sim,debug)
	rm -rf -- $@
	xcodebuild -create-xcframework $(foreach lib,$^,-library ${lib}) -output $@

$(call xcframework_out,release): $(call xcarchive_out,ios,release) $(call xcarchive_out,sim,release)
	rm -rf -- $@
	xcodebuild -create-xcframework $(foreach lib,$^,-library ${lib}) -output $@

clean:
	rm -rf -- bin/*

godot:
	if [ ! -d "$@" ] ; then \
		git clone --depth 1 -b ${GODOT} ${GODOT_SRC} $@; \
	fi
	cd $@ && ${SCONS} p=ios target=template_debug arch=arm64

.PHONY: all debug release clean godot
