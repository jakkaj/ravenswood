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

ARG HEART_BEAT_FOLDER
ENV HEART_BEAT_FOLDER=${HEART_BEAT_FOLDER}

ARG THIS_CLUSTER
ENV THIS_CLUSTER=${THIS_CLUSTER}

ARG THAT_CLUSTER
ENV THAT_CLUSTER=${THAT_CLUSTER}

CMD ["dotnet", "HeartBeatFS.dll"]