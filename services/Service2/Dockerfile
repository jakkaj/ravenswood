FROM microsoft/dotnet:2.1-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src
COPY Service2.csproj ./
RUN dotnet restore Service2.csproj
COPY . .
WORKDIR /src
RUN dotnet build Service2.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish Service2.csproj -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "Service2.dll"]
