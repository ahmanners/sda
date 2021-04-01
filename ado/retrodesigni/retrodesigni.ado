program retrodesigni // , rclass
    version 14.2
    
    syntax anything                     ///
    [ ,                                 ///
        Level(cilevel)                     ///
        DF(numlist integer max = 1 > 0) ///
        NSIMs(integer 10000)             ///
    ]
    
    if (`nsims' < 1) {
        display as err "nsims() invalid -- " _continue
        error 125
    }
    
    gettoken b     anything : anything
    gettoken se anything : anything
    if (`"`anything'"' != "") {
        error 198
    }
    capture noisily confirm number `b'
    if (_rc) {
        exit 198
    }
    capture noisily assert (`se' > 0)
    if (_rc) {
        exit 198
    }
    
    tempname power typeS ex
    mata : retrodesigni_ado()
    
    display
    display as txt %12s "b"         " = " as res `b'
    display as txt %12s "se"         " = " as res `se'
    display as txt %12s "level"     " = " as res `level'
    display
    display as txt %12s "power"     " = " as res r(power)
    display as txt %12s "typeS"     " = " as res r(typeS)
    display as txt %12s "Exagg."     " = " as res r(exaggeration)
end

version 14.2

mata :

void retrodesigni_ado()
{
    real scalar b, se, alpha, df, nsims
    real scalar z, lo, hi, power, typeS, exagg
    real colvector coef
    
    b         = strtoreal(st_local("b"))
    se         = strtoreal(st_local("se"))
    alpha     = 1-strtoreal(st_local("level"))/100
    df         = strtoreal(st_local("df"))
    nsims     = strtoreal(st_local("nsims"))
    
    if (missing(df)) {
        z         = invnormal(1-alpha/2)
        lo         = normal(-z-b/se)
        hi         = 1-normal(z-b/se)
        coef     = b:+se:*rnormal(nsims, 1, 0, 1)
    }
    else {
        z         = (-1)*invttail(df, 1-alpha/2)
        lo         = 1-ttail(df, -z-b/se)
        hi         = ttail(df, z-b/se)
        coef     = b:+se:*rt(nsims, 1, df)
    }
    
    power = hi+lo
    typeS = lo/power
    exagg = mean(abs(select(coef, abs(coef):>(se*z))))/b
    
    st_rclear()
    st_numscalar("r(power)", power)
    st_numscalar("r(typeS)", typeS)
    st_numscalar("r(exaggeration)", exagg)
}

end

