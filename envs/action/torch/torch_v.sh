#!/usr/bin/env bash

python3 -c 'import torch; \
            print("torch version is:", torch.__version__); \
            print("cuda is available: ", torch.cuda.is_available()); \
            print("cuda device count is: ", torch.cuda.device_count()); \
            print("device name is: ", torch.cuda.get_device_name(0) if torch.cuda.is_available() else "No GPU"); \
            vector1 = torch.tensor([1.0, 2.0, 3.0, 4.0], device="cuda"); \
            vector2 = torch.tensor([2.0, 3.0, 4.0, 5.0], device="cuda"); \
            dot_product3 = torch.matmul(vector1, vector2); \
            print(f"使用matmul: {dot_product3}")'