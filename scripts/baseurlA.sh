#!/bin/bash

export BASE_URL="$1"
export STAGE="$2"
pytest --junitxml=result-rest.xml test/integration/todoApiTestA.py