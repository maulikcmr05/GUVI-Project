# GUVI Project – Big Data with Docker (Hadoop)

A Dockerized Hadoop environment (HDFS + YARN) used to import a CSV dataset into HDFS and process it.

## Project Overview

<!-- Replace with 2-3 lines about YOUR project: what dataset, what goal. -->
This project sets up a Hadoop cluster using Docker containers and loads a CSV file into HDFS using `docker exec`.

## Architecture

| Container         | Role                                   |
|-------------------|----------------------------------------|
| `namenode`        | HDFS master, stores file metadata      |
| `datanode`        | HDFS worker, stores the actual data    |
| `resourcemanager` | YARN master, schedules jobs            |
| `nodemanager`     | YARN worker, runs tasks                |

## Prerequisites

- Docker (20.10+)
- Docker Compose (v2)
- Git
- At least 4 GB of free RAM

## Project Structure

```
GUVI-Project/
├── docker-compose.yml
├── setup.sh
├── data/
│   └── data.csv        # your dataset
└── README.md
```

## Setup and Usage

### 1. Clone the repository
```bash
git clone https://github.com/maulikcmr05/GUVI-Project.git
cd GUVI-Project
```

### 2. Run the setup script
```bash
chmod +x setup.sh
./setup.sh ./data/data.csv
```

The script will:
1. Start all containers (`docker compose up -d`)
2. Wait for HDFS to be ready
3. Copy the CSV into the namenode container
4. Import it into HDFS at `/user/root/input`
5. Verify the file and the nodemanager

### 3. Manual commands (optional)

```bash
# Enter the namenode
docker exec -it namenode bash

# List files in HDFS
docker exec namenode hdfs dfs -ls /user/root/input

# View the first lines of the CSV
docker exec namenode hdfs dfs -cat /user/root/input/data.csv | head

# Check YARN nodes
docker exec resourcemanager yarn node -list
```

## Web Interfaces

| Service           | URL                    |
|-------------------|------------------------|
| HDFS Namenode     | http://localhost:9870  |
| YARN ResourceMgr  | http://localhost:8088  |

## Stopping the Cluster

```bash
docker compose down        # stop containers
docker compose down -v     # stop and delete volumes (removes HDFS data)
```

## Troubleshooting

- **Container name not found**: run `docker ps` and update the names at the top of `setup.sh`.
- **HDFS stuck in safe mode**: `docker exec namenode hdfs dfsadmin -safemode leave`
- **Port already in use**: change the port mapping in `docker-compose.yml`.
- **CSV not found**: check the path you pass to `setup.sh`.

## Technologies Used

- Docker, Docker Compose
- Apache Hadoop (HDFS, YARN)
<!-- Add Hive / Spark / MapReduce here if you use them -->

## Author

Maulik – [GitHub](https://github.com/maulikcmr05)
