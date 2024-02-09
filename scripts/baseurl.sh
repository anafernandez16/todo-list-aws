#!/bin/bash

export BASE_URL="$1"
pytest --junitxml=result-rest.xml test/integration/todoApiTest.py