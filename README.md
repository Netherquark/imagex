# 🖼️ imagex

This project is a MATLAB implementation of a simple image processing manager for applying 3x3 convolution kernels (filters) to RGB images. It includes a core class (`ImageEnhancer`), a manual convolution function, a non-interactive demonstration script, and a basic Graphical User Interface (GUI).

The primary goal is to demonstrate Object-Oriented Programming (OOP) principles in MATLAB while providing a hands-on example of 2D image convolution with various boundary padding modes.

---

## 🚀 Getting Started

### Prerequisites

* **MATLAB** (R2018a or newer is recommended for full GUI functionality).
* The project assumes an image file named `peppers.png` exists in the directory for the `main.m` demonstration script to run successfully. This image is commonly included with MATLAB.

### Running the Code

1.  **Download:** Clone or download all the files into a single directory.
2.  **Set Path:** Open MATLAB and set the current folder to the project directory.
3.  **Run Demos:**
    * **Interactive GUI:** Type `mainUI` in the MATLAB Command Window. This allows you to upload an image, select a kernel, and choose a processing mode (RGB or single channel).
    * **Scripted Demo:** Type `main` in the MATLAB Command Window. This runs a non-interactive script that compares several filters on a grayscale image and demonstrates RGB sharpening.

---

## 📁 Project Structure

| File | Description |
| :--- | :--- |
| `ImageEnhancer.m` | **Core Class.** Manages image loading, normalization, kernel definitions, and coordinates the filtering of individual channels. |
| `conv2d_manual.m` | **Core Function.** Implements the 2D convolution algorithm using nested loops, supporting custom boundary padding. |
| `main.m` | **Scripted Demonstration.** Runs several examples using the `ImageEnhancer` class and `conv2d_manual` for comparison. |
| `mainUI.m` | **Graphical User Interface (GUI).** Provides an interactive way to test the filters and modes. |

---

## 🔧 Core Components Details

### `ImageEnhancer` Class

The class constructor accepts either an image file path (string) or a numeric HxWx3 image matrix. It normalizes all inputs to an `uint8` HxWx3 format.

#### **Defined Kernels**
The class includes a static method `defineKernels()` with the following pre-defined 3x3 filters:

* `Identity`
* `Box` (Averaging/Blurring)
* `Sharpen`
* `Gaussian`
* `SobelV` (Vertical Edge Detection)
* `SobelH` (Horizontal Edge Detection)
* `Laplacian` (Edge Detection)
* `Emboss`

#### **Processing Methods**

* `processChannel(channelChar, kernelNameOrMatrix)`: Filters a single channel ('R', 'G', or 'B').
* `processRGB(kernelNameOrMatrix)`: Filters all three channels independently and combines the results.

### `conv2d_manual` Function

This function handles the low-level mechanics of convolution. It converts the input channel to **double** for computation and flips the kernel 180 degrees to conform to the mathematical definition of convolution.

#### **Supported Padding Modes**
The function supports three boundary handling strategies for a 3x3 kernel (1-pixel padding):

1.  **`zero`**: Fills the border with zeros (default for standard signal processing).
2.  **`replicate`**: Copies the edge pixels outward.
3.  **`reflect`**: Mirrors the internal pixels across the boundary (symmetric padding).
