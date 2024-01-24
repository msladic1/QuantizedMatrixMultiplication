# QMM - Quantized Matrix Multiplication

## Instalation
The package is not registered and this can be installed in the following way
```
add https://github.com/msladic1/QuantizedMatrixMultiplication.jl
```

## Project Description
This project is a first step in introducing multiplication of Quantized Matrix with Regular Float Matrix, in Julia.

The first part of the project consists of turning Float32 matrix to Quantized version. The code of these functions can be found in **quant_functions.jl** file.
Quantization is based on this [paper](https://arxiv.org/pdf/2310.10537.pdf) *Microscaling Data Formats for Deep Learning* by Rouhani et. al.

The second part of the project is focused on implementing multiplication of this quantized matrix with regular floating point matrix. This code can be found in **multiplication.jl** file.

## Usage
This package offers functions that will turn regular Float matrix into a Quantized matrix, where values are of type Int8.
The file **run_example.jl** provides examples of usage also.

To get quantized matrix, two functions need to be called: 
```
convert_to_quant_matrix(floatMatrix)
pack(quant_matrix, scales)
```
Parameters * *quant_matrix* * and * *scales* * are return values of * *convert_to_quant_matrix* * function.
First function will quantize float values to Int8 precission. 
The secon function will pack that matrix into a QuantMatrix, which consists of Chunks of 4 quantized values and their quantization scale.

To multiply QuantizedMatrix with regular Float precission matrix it is sufficient to do
```
result = quantized_matrix * regular_matrix
```
