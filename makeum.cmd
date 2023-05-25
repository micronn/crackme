@echo off
ml /c cmelib.asm && cl cme.c /link /subsystem:console cmelib.obj
