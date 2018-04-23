using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libcfitsio"], :libcfitsio),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/mweastwood/CFITSIOBuilder/releases/download/v3.440-1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    BinaryProvider.Linux(:aarch64, :glibc, :blank_abi) => ("$bin_prefix/CFITSIO.aarch64-linux-gnu.tar.gz", "61b80ea0d01195878b6bbf1cae3cd2e882d5ae3b2528f27dd39b473290fce5bf"),
    BinaryProvider.Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/CFITSIO.arm-linux-gnueabihf.tar.gz", "7d4538b1141b717fc82424bb5ea8c9e25b2932b342fc5f6a821b2f1d4f898241"),
    BinaryProvider.Linux(:i686, :glibc, :blank_abi) => ("$bin_prefix/CFITSIO.i686-linux-gnu.tar.gz", "df51f0609d8093168e15dd3721aa76b36b3bc0ac97e06945d7ba01c6125087f8"),
    BinaryProvider.Windows(:i686, :blank_libc, :blank_abi) => ("$bin_prefix/CFITSIO.i686-w64-mingw32.tar.gz", "0ace7f33ec3187241f7ce5fb108be9e2e58e7dea22b9772803eb3cb251804fee"),
    BinaryProvider.Linux(:powerpc64le, :glibc, :blank_abi) => ("$bin_prefix/CFITSIO.powerpc64le-linux-gnu.tar.gz", "60e8cf7b06bcf25aa033f56d037c3149e83502632116c7191a84abdf72443bbd"),
    BinaryProvider.MacOS(:x86_64, :blank_libc, :blank_abi) => ("$bin_prefix/CFITSIO.x86_64-apple-darwin14.tar.gz", "1f0e018b7337258752b8e5bcc51d9b584dcb2464a7e3d2935bc22f09e46befae"),
    BinaryProvider.Linux(:x86_64, :glibc, :blank_abi) => ("$bin_prefix/CFITSIO.x86_64-linux-gnu.tar.gz", "117ee2ab1be15d86508d915bafc4a9597c4238c1ec74d1cdfb68c8b14707537a"),
    BinaryProvider.Windows(:x86_64, :blank_libc, :blank_abi) => ("$bin_prefix/CFITSIO.x86_64-w64-mingw32.tar.gz", "582c57a5b174dbefc3321318ac8050f1da0432e2fd39c9eba053b6db4ac47514"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something more even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
