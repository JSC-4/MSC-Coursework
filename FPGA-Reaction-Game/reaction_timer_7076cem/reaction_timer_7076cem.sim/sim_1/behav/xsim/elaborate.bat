@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.1 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Wed Mar 23 16:27:36 +0000 2022
REM SW Build 2552052 on Fri May 24 14:49:42 MDT 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
echo "xelab -wto 6a56d17d72de435fa911c0971cc8612e --incr --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot bin2bcd_tb_behav xil_defaultlib.bin2bcd_tb -log elaborate.log"
call xelab  -wto 6a56d17d72de435fa911c0971cc8612e --incr --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot bin2bcd_tb_behav xil_defaultlib.bin2bcd_tb -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0