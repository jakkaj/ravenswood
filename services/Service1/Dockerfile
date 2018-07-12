FROM microsoft/dotnet:2.1.1-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src
COPY Service1.csproj ./
RUN dotnet restore Service1.csproj
COPY . .
WORKDIR /src/
RUN dotnet build Service1.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish Service1.csproj -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "Service1.dll"]
