faultdef DIVISION_BY_ZERO;

fn double? divide(int a, int b)
{
    if (b == 0) return DIVISION_BY_ZERO~;
    return (double)(a) / (double)(b);
}

fn void test_fn() @test
{
    test::@check(2 == 2, "divide: %d", divide(6, 3)!!);
}