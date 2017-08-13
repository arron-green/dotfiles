for python_version in 2.7.10 2.7.13 3.3.6 3.6.1; do
    CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv install -s $python_version
done
