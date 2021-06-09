
## Horust

Tested only on linux-like systems, ( gentoo, debian, HURD-6.1 ).

Unfortunately it does not compile on macOS.

### Setup

```
cargo install horust
```

We need a softlink to your CDL repo create it in root of this repo, this process will be later automated
`ln -s /path/to/your/repo/CommonDataLayer cdl`

We need debug build present.
```
cd cdl
cargo build --all --all-features
cd ../
```

### Infrastructure
start all necessary dependencies with logging output to console
```
docker-compose -f compose/docker-compose.yml up postgres kafka
```

alternatively start as daemons  only use when the deployment is stable on your setup
```
docker-compose -f compose/docker-compose.yml up -d postgres kafka
```

### Start Deployment

```
export CDL_CONFIG="cdl/.cdl"
horust --services-path bare/horust/kafka/base --services-path bare/horust/kafka/postgres &
```

### Release
To build and run release target:

``` sh
cd cdl
cargo build --all --all-features --release
cd ../
TARGET=release horust --services-path bare/horust/kafka/base --services-path bare/horust/kafka/postgres
```

### Examples
Examples expect to be ran from this directory

``` sh
./examples/horust-kafka-postgres.sh
```
The example script builds all crates automatically. By default it builds and uses `debug` target, but you may want to change it to release by passing `--release` flag:

``` sh
./examples/horust-kafka-postgres --release
```

The example script supports initializing required infrastructure dependencies. It uses `compose/docker-compose.yml` and then waits 15 seconds.

``` sh
./examples/horust-kafka-postgres --infra
```

The example script also has included mechanism to clean state by removing dependencies (when combined with `--infra`), but also logs and storage for schema registry. To do so use `--clean` flag:

``` sh
./examples/horust-kafka-postgres --clean
```

User can use all flags together:

``` sh
./examples/horust-kafka-postgres --clean --infra --release
```
This will:

* Build all crates in release target
* Kills and removes storage for all dependencies
* Removes schema registry DB
* Removes all logs
* Initializes new docker containers with depenencies
* Waits 15 seconds
* Runs all services in release mode

### Logs
Logs are placed in the `logs` subfolder where you run the horust from

in case of problems with EONET or some other problem, good changes are
that its either missing exec or not existing directory

there are some docs about service files available here https://github.com/FedericoPonzi/Horust

To see whats going on in horust itself use
`HORUST_LOG=info horust ...`

