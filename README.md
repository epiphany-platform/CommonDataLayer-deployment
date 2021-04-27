
## Horust

Tested only on unix-like systems, ( gentoo, debian, ArchHurd 2020-11-22  )

### Setup

#### Installing
TODO: Wait until my changes in Horust gets merged (https://github.com/FedericoPonzi/Horust/pull/56)

```
cargo install horust
```

#### Updating
cargo-update is required, install it if you do not have it already
`cargo install cargo-update`

updating process itself:
`cargo install-update horust`

### Providing CommonDataLayer sources
Horust expects `cdl` folder to either point or contain

#### Git submodule
If you wish, you can either create softlink to existing cdl repo, or initialize it as a submodule
repo initialized as a submodule will use ssh method of clone to get a fresh repo with specific commit and branch that should work with current deployment.
To do that:
`git submodule update --init`


#### Softlinking
Softlinking also does have its pros and cons.
You do not need to create another copy of cdl repo, and you can link your current, existing repository.
What's problematic is that you have to be really sure that branch you are pointing on is compatible with the deployment branch.

To do that:
```
rmdir cdl
ln -s /path/to/your/repo/CommonDataLayer cdl
```

#### Notes:
Unfortunately, linking may lead to problems with commits.
Please note that the current working commit in cdl witll be available in `version.nfo`.
It is developer responsibility to update those files during update for this repo.
Additionally not every cdl commit must have its own deployment commit. Some of those will be skipped, especially for the develop.
All "master" releases of cdl will have its deployments here, tagged, on master branch.


### Source builds:
We need debug build present.
```
cd cdl
cargo build --all --all-features
cd ../
```

### Infrastructure:

#### Isolated (via docker-compose):
start all necessary dependencies with logging output to console
```
docker-compose -f compose/docker-compose.yml up postgres kafka
```

alternatively start as daemons  only use when the deployment is stable on your setup
```
docker-compose -f compose/docker-compose.yml up -d postgres kafka
```

#### Native
Alternatively you can use your own installations in current system. Ports should be the same as in the docker-compose, and in turn fully compatible (unless something is really customized on your system). In that case you can just skip whatever you have natively.

Mind that if you have local services (i.e. Postgres), and you do not want to use those and go with docker-compose instead, please stop those services, or port clashing will occur.

Accidentally runnign cdl against native services shouldn't harm your databases. Services will crash but no long term changes should happen. CDL to work requirers specific state of the databases and withouit initialization script it wont work.

### Start Deployment:

```
horust --services-path bare/horust/kafka/base --services-path bare/horust/kafka/postgres &
```

### CDL Release version:
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

### Logs:
Logs are placed in the `logs` subfolder where you run the horust from

in case of problems with EONET or some other problem, good changes are
that its either missing exec or not existing directory

Recommended tool to navigate logs is `lnav`

Logs are persistant. You have to clean them yourself manually.

### More:
there are some docs about service files available here https://github.com/FedericoPonzi/Horust

To see whats going on in horust itself use
`HORUST_LOG=info horust ...`

