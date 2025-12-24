#!/usr/bin/env bash

python3 -c 'import torch; \
            print("torch version is:", torch.__version__); \
            print("cuda is available: ", torch.cuda.is_available()); \
            print("cuda device count is: ", torch.cuda.device_count()); \
            print("device name is: ", torch.cuda.get_device_name(0) if torch.cuda.is_available() else "No GPU")'