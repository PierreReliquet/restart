#!/bin/bash
for fileName in $(ls test|grep ".dart")
do
	dart "test/$fileName";
done
