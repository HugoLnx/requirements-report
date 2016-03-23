#!/bin/bash
docker run -v $PWD:/app --rm requirement-report ruby generate_report.rb $1
