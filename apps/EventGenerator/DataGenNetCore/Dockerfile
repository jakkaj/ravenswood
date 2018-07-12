FROM microsoft/dotnet:2.1-sdk AS BUILD
WORKDIR /app


# Copy the project and restore packages
COPY *.csproj ./
RUN dotnet restore

# Copy rest and build
COPY . ./
RUN dotnet publish -c Release -o out

# build runtime inage
# use slow|fast|faster|insane as options for message sending speed
# ARG is not used in ENTRYPOINT, so using ARG -> ENV -> ENTRYPOINT
FROM microsoft/dotnet:2.1-aspnetcore-runtime
WORKDIR /app
COPY --from=BUILD /app/out .
ARG VELOCITY
ENV VELOCITY=${VELOCITY}
#ENTRYPOINT dotnet DataGenNetCore.dll sendmessages ${VELOCITY}

#CMD ["sendmessages","${VELOCITY}"]


CMD ["/bin/bash"]