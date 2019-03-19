#!/usr/bin/env bash

# Create Virtual Environment

rm -rf g6k-env
virtualenv g6k-env
cat <<EOF >>g6k-env/bin/activate
### LD_LIBRARY_HACK
_OLD_LD_LIBRARY_PATH="\$LD_LIBRARY_PATH"
LD_LIBRARY_PATH="\$VIRTUAL_ENV/lib:\$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH
### END_LD_LIBRARY_HACK

### PKG_CONFIG_HACK
_OLD_PKG_CONFIG_PATH="\$PKG_CONFIG_PATH"
PKG_CONFIG_PATH="\$VIRTUAL_ENV/lib/pkgconfig:\$PKG_CONFIG_PATH"
export PKG_CONFIG_PATH
### END_PKG_CONFIG_HACK
      
CFLAGS="\$CFLAGS -O3 -march=native -Wp,-U_FORTIFY_SOURCE"
CXXFLAGS="\$CXXFLAGS -O3 -march=native -Wp,-U_FORTIFY_SOURCE"
export CFLAGS
export CXXFLAGS
EOF

source g6k-env/bin/activate

#pip install -U pip

# Install FPLLL

git clone https://github.com/fplll/fplll --depth 1
cd fplll 
git fetch --unshallow|| exit
./autogen.sh
./configure --prefix="$VIRTUAL_ENV" $CONFIGURE_FLAGS
make clean
make -j 10
make install
cd ..

# Install FPyLLL
git clone https://github.com/fplll/fpylll --depth 1
cd fpylll 
git fetch --unshallow||exit
pip install Cython -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install numpy -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install cysignals -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install ipython -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install begins -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install pytest -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install scipy -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install Sphinx -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install flake8 -i https://pypi.tuna.tsinghua.edu.cn/simple

pip install multiprocessing -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install -r requirements.txt
pip install -r suggestions.txt
python setup.py clean
python setup.py build_ext
python setup.py install
cd ..

pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install multiprocessing-logging -i https://pypi.tuna.tsinghua.edu.cn/simple
python setup.py clean
python setup.py build_ext --inplace

# Otherwise py.test may fail

rm -rf ./fplll
rm -rf ./fpylll
 