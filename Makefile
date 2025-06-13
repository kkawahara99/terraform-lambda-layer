.PHONY: layer-package clean test

LAYER_SRC  := src/layers/shared
BUILD_ROOT := $(LAYER_SRC)/build
PY_DIR     := $(BUILD_ROOT)/python
DIST_DIR   := dist

layer-package:
	rm -rf $(BUILD_ROOT) $(DIST_DIR)/shared_layer.zip
	mkdir -p $(PY_DIR) $(DIST_DIR)

	# 依存を vendor
	pip install -r $(LAYER_SRC)/requirements.txt -t $(PY_DIR)
	# 自前ライブラリ
	cp -R $(LAYER_SRC)/mylib $(PY_DIR)/

	# ★ build/python を python/ という名前で ZIP root に入れる
	cd $(BUILD_ROOT) && \
		zip -qr $(CURDIR)/$(DIST_DIR)/shared_layer.zip python

clean:
	rm -rf $(BUILD_ROOT) $(DIST_DIR)

test:
	pytest -q