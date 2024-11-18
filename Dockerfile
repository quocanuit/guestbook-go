# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Step 1: Use Go base image
FROM golang:1.18.0

# Set the working directory inside the container
WORKDIR /app

# Initialize a Go module and fetch dependencies
RUN go mod init myapp && \
    go get github.com/codegangsta/negroni \
           github.com/gorilla/mux \
           github.com/xyproto/simpleredis/v2

# Add the Go source code to the working directory
ADD ./main.go .

# Build the Go application (for Linux)
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Step 2: Create a minimal container for the application
FROM scratch

# Set the working directory inside the minimal container
WORKDIR /app

# Copy the compiled binary from the build stage
COPY --from=0 /app/main .

# Copy static files (HTML, JS, CSS)
COPY ./public/index.html public/index.html
COPY ./public/script.js public/script.js
COPY ./public/style.css public/style.css

# Define the command to run the binary
CMD ["/app/main"]

# Expose the application's port
EXPOSE 3000