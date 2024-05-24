CLASS = PluginExample
OUT = godot_example
GODOT = 4.2.1-stable
GODOT_SRC = https://github.com/godotengine/godot.git
SCONS = scons

build: clean
	@mkdir -p bin
	SWIFT_FLAGS="${SWIFT_FLAGS}" CLASS="${CLASS}" OUT="${OUT}" ./generate_static_library.sh

clean:
	rm -rf -- bin/*

godot:
	if [ ! -d "$@" ] ; then \
		git clone --depth 1 -b ${GODOT} ${GODOT_SRC} $@; \
	fi
	cd $@ && ${SCONS} p=ios target=template_debug arch=arm64

.PHONY: build clean godot
