## Custom llama.cpp Build for LM Studio: 1-bit Prism Bonsai Support

This guide details how to compile a patched version of `llama.cpp` to enable **1-bit inference** for Prism Bonsai models within LM Studio using the NVIDIA CUDA runtime.

## Prerequisites in Windows (Tested with Windows 11)

* **Nvidia Toolkit:** Version 13.2 (used during testing)
* **LM Studio:** Installed with the CUDA 12 backend extension
* **Git and CMake:** Installed and configured in your system PATH
* **Microsoft Visual Studio 2022 or later**. Install with the **"Desktop development with C++"** workload.

## Repository Information

* **Mintplex-Labs Fork:** [prism-ml-llama.cpp](https://github.com/Mintplex-Labs/prism-ml-llama.cpp) (Tag: [prism-b8656-520d93d](https://github.com/Mintplex-Labs/prism-ml-llama.cpp/releases/tag/prism-b8656-520d93d))
* **Upstream:** [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) (Last tested release: [b8664](https://github.com/ggml-org/llama.cpp/tree/b8664))
* **Model:** [Bonsai-8B-gguf](https://huggingface.co/prism-ml/Bonsai-8B-gguf)

---

## 1. Clone and Patch the Repository

Open your terminal and run the following commands to clone the fork and merge it with the latest upstream changes:

```powershell
git clone https://github.com/Mintplex-Labs/prism-ml-llama.cpp
cd prism-ml-llama.cpp

git remote add upstream https://github.com/ggml-org/llama.cpp.git
git fetch upstream

# Merge upstream changes
git merge upstream/master
```

> **Note:** If you encounter a "Committer identity unknown" error, configure your git identity:
> ```powershell
> git config user.email "user@local.com"
> git config user.name "user"
> git merge upstream/master
> ```

---

## 2. Build the Binaries

Create a build directory and compile the project using CMake. Ensure you specify your specific GPU architecture (e.g., `89` for RTX 40-series).

```powershell
mkdir build
cd build

cmake .. -A x64 -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=89 -DGGML_AVX2=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="/w" -DCMAKE_C_FLAGS="/w"

cmake --build . --config Release -j
```

*If you need to restart the build from scratch:*
```powershell
cd ..
Remove-Item -Recurse -Force build
mkdir build
cd build
```

---

## 3. Integrate with LM Studio

To use your custom build in LM Studio, you must create a custom backend extension folder.

1.  Navigate to your LM Studio extensions directory:
    `%UserProfile%\.lmstudio\extensions\backends\`
2.  Locate the folder: `llama.cpp-win-x86_64-nvidia-cuda12-avx2-2.11.0` (this was the runtime in LMstudio for nvidia during the time of testing)
3.  **Copy** that folder and rename the copy to: `llama.cpp-win-x86_64-nvidia-cuda12-avx2-1.0.0`
4.  Open `backend-manifest.json` inside the new folder.
5.  Change the version string from `"2.11.0"` to `"1.0.0"` and save.

### Copy the Binaries
Copy all `.dll` files from your build output:
`prism-ml-llama.cpp\build\bin\Release\`

Paste and overwrite them into the LM Studio folder:
`%UserProfile%\.lmstudio\extensions\backends\llama.cpp-win-x86_64-nvidia-cuda12-avx2-1.0.0\`

---

## 4. Loading the Model

1.  Open **LM Studio**.
2.  Go to the **Local Server** or **AI Chat** settings.
3.  Under the Runtime/Backend selection, choose **Cuda 12 llama.cpp v1.0.0**.
4.  Load the **1bit Bonsai-8B** model.
