MGEScan on Galaxy Scientific Workflow
===============================================================================

A Galaxy based system for identifying retrotransposons in genome

![mgescan workflow](https://raw.githubusercontent.com/MGEScan/mgescan/master/docs/source/images/rtm-workflow-final.png)

* [Tutorial](http://mgescan.readthedocs.org/en/latest/tutorial.html)
* [Documentation](http://mgescan.readthedocs.org/en/latest/index.html)
* [Source](https://github.com/MGEScan/mgescan/)
* [Home Page](http://mgescan.github.io/mgescan/)

Prerequisite
-------------------------------------------------------------------------------

### Python

* git
* virtualenv
* python-dev

```sh
sudo apt-get update
sudo apt-get install python-virtualenv -y
sudo apt-get install git -y
sudo apt-get install python-dev -y
```

#### Virtualenv


```sh
mkdir ~/virtualenv
virtualenv ~/virtualenv/mgescan
source ~/virtualenv/mgescan/bin/activate
echo "source ~/virtualenv/mgescan/bin/activate" >> ~/.bash_profile
```

### Tools

* Galaxy
* HMMER
* EMBOSS
* trf (Tandem Repeats Finder)

#### Galaxy
```sh
cd ~/
git clone https://github.com/galaxyproject/galaxy/
```

#### HMMER and EMBOSS

*Ubuntu*

```sh
sudo apt-get install hmmer -y
sudo apt-get install emboss -y
```

#### trf

```sh
wget http://tandem.bu.edu/trf/downloads/trf407b.linux64
mv trf407b.linux64 ~/virtualenv/mgescan/bin/trf
chmod 700 ~/virtualenv/mgescan/bin/trf
```

#### RepeatMasker

```sh
cd ~
wget http://www.repeatmasker.org/RepeatMasker-open-4-0-5.tar.gz
tar xvzf RepeatMasker-open-4-0-5.tar.gz
```

>> Find the latest at: http://www.repeatmasker.org/RMDownload.html

Installation
-------------------------------------------------------------------------------

```sh
git clone https://github.com/MGEScan/mgescan.git
cd mgescan
python setup.py install
```

### virtualenv (optional for individual without sudo)


```sh
virtualenv ~/virtualenv/mgescan
source ~/virtualenv/mgescan/bin/activate
```

### Galaxy modification

```sh
cd ~/
cp -pr ~/mgescan/galaxy-modified/* ~/galaxy
```

### Start Galaxy
```sh
cd ~/galaxy
./run.sh &
```

Default port number : **38080**
http://[IP ADDRESS]:38080

Command Line Tool (mgescan)
-------------------------------------------------------------------------------

```sh
Usage:
    mgescan both <genome_dir> [--output=<data_dir>] [--mpi=<num>]
    mgescan ltr <genome_dir> [--output=<data_dir>] [--mpi=<num>]
    mgescan nonltr <genome_dir> [--output=<data_dir>] [--mpi=<num>]
    mgescan (-h | --help)
    mgescan --version
```

Amazon Cloud Image (EC2)
-------------------------------------------------------------------------------

* US East (Ohio) Region Only
* MGEScan - ami-394ebd52 (latest version)
* retrotminer-alpha - ami-23d9c74a (created at 2014)

>> Old AMIs need to get an update of MGEScan, run the following commands after launching a new instance, and restart the server.

```sh
(Stop galaxy server first - processs looks like 'python ./scripts/paster.py serve universe_wsgi.ini')
sudo yum update -y
cd $MGESCAN_SRC;git pull;python setup.py install
cd $GALAXY_HOME;git pull;./run.sh;sh manage_db.sh -c ./universe_wsgi.ini upgrade
cp -pr $MGESCAN_SRC/galaxy-modified/* $GALAXY_HOME
cd $GALAXY_HOME;nohup bash run.sh &
```




Citation
-------------------------------------------------------------------------------

@article{lee2016mgescan,
  title={MGEScan: a Galaxy-based system for identifying retrotransposons in genomes},
  author={Lee, Hyungro and Lee, Minsu and Mohammed Ismail, Wazim and Rho, Mina and Fox, Geoffrey C and Oh, Sangyoon and Tang, Haixu},
  journal={Bioinformatics},
  volume={32},
  number={16},
  pages={2502--2504},
  year={2016},
  publisher={Oxford University Press}
}

Web Sites
-------------------------------------------------------------------------------

* [MGEScan-LTR](http://darwin.informatics.indiana.edu/cgi-bin/evolution/daphnia_ltr.pl)
* [MGEScan-nonLTR](http://darwin.informatics.indiana.edu/cgi-bin/evolution/nonltr/nonltr.pl)

License
-------------------------------------------------------------------------------

Copyright (C) 2015. See the LICENSE file for license rights and limitations
(GPL v3).

This program is part of MGEScan.

MGEScan is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
