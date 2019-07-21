sizes:
	g++ scripts/sizesAndOffsets.c \
	  -o scripts/sizesAndOffsets \
	  -I/usr/include/SuperCollider/plugin_interface/ \
	  -I/usr/include/SuperCollider/common/
	./scripts/sizesAndOffsets
