#ifndef G6K_SIMHASH_INL
#define G6K_SIMHASH_INL

#ifndef G6K_SIEVER_H
#error Do not include siever.inl directly
#endif

// choose the vectors sparse vectors r_i for the compressed representation
inline void SimHashes::reset_compress_pos(Siever const &siever)
{
    n = siever.n;
    if (n < 30)
    {
        for(size_t i = 0; i < XPC_BIT_LEN; ++i)
        {
            for(size_t j = 0; j < 6; ++j)
            {
                compress_pos[i][j] = 0;
            }
        }
        return;
    }

    size_t x, y;
    std::string const filename = siever.params.simhash_codes_basedir
      + "/spherical_coding/sc_"+std::to_string(n)+"_"+std::to_string(XPC_BIT_LEN)+".def";
    std::ifstream in(filename);
    std::vector<int> permut;

    // create random permutation of 0..n-1:
    permut.resize(n);
    std::iota(permut.begin(), permut.end(), 0);
    std::shuffle(permut.begin(), permut.end(), sim_hash_rng);

    if (!in)
    {
        std::string s = "Cannot open file ";
        s += filename;
        throw std::runtime_error(s);
    }

    for (y = 0; y < XPC_BIT_LEN; y++)
    {
        for (x = 0; x < 6; x++)
        {
            int v;
            in >> v;
            compress_pos[y][x] = permut[v];
        }
    }
    in.close();
}


// Compute the compressed representation of an entry
inline CompressedVector SimHashes::compress(std::array<LFT,MAX_SIEVING_DIM> const &v) const
{
    ATOMIC_CPUCOUNT(260);
    CompressedVector c = {0};
    if (n < 30) return c;
    for (size_t j = 0; j < XPC_WORD_LEN; ++j)
    {
        uint64_t c_tmp = 0;
        LFT a = 0;
        for (size_t i = 0; i < 64; i++)
        {
            size_t k = 64 * j + i;
            a   = v[compress_pos[k][0]];
            a  += v[compress_pos[k][1]];
            a  += v[compress_pos[k][2]];
            a  -= v[compress_pos[k][3]];
            a  -= v[compress_pos[k][4]];
            a  -= v[compress_pos[k][5]];

            c_tmp = c_tmp << 1;
            c_tmp |= (uint64_t)(a > 0);
        }
        c[j] = c_tmp;
    }
    return c;
}


#endif
