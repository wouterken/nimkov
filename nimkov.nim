import ssm

const keys = ["UBEMQXVzbmegOiV", "ySOwRDulkelSbsl", "PWGTnHldVHHWhjd", "EDaQqakUEmNidZB", "uBzzootzXZMHvzv", "qKtESmjTYSFnxwx", "FqYwPvwlBuorCXO", "lbipKmBvzXaJsJN", "sgIwQSFpXTiUufn", "uOkxVPZeHIPaFSu", "qbylIvXpefMcICn", "oYHjHRhJBXahvCl", "kRnXwclbBSjFTlJ", "buCniGFjzOEBbrS", "YjnikYlpkpPZbVh", "xhtCBNQVTbclzgf", "oymPGspYEaUgGuc", "ayuYrkXvQTRlDgp", "TGRXaNkAGFWSRwq", "AUdORnxagQFnsot", "BmfnDLhnbguOznX", "eeRwwdwEofzbVFZ", "ValaaqiJhKpJOgQ", "odEpgzzjLGVebbB", "ElHqHWoyFpraMxQ", "WdTTWcCxURGwSGx", "KRXJEAdHGALtsJn", "rralEKtLmtKveWf", "WrYtxASrMKfuhNA", "qdSZFSevJeASKiy", "DcPyHyjvnwSWKsW", "ApAoMoOWfleJERZ", "kkeKHXQyJnrZEqT", "xHEfBDNsvDijTHK", "GLJJFOImworMyyt", "rzMKHHPLgpjoBdp", "jByJOYOJtejLJuJ", "NJxMRfgGLJkwsSN", "JOOnUUMzcocXxlK", "NWKBhoIKlHjbitw", "RtJuIrHIGggXrDK", "lKofyTSnZgymmOl", "NldsoCdRUMdaNKB", "UDSirZDMxoqXTcr", "WquXUzoAqsCFFeI", "QQYlqtNMUKIOVJy", "HalHRkBvTIOsDaY", "zqwFlymjyNuMQOB", "GGIMvLMJiJiaImE", "AWTaMAqxiZgyPGO", "tmuGVQZgezRtbaG", "PYWTFWVIhXennbS", "WjvpUKIfFevEElo", "xBvdZnabPkYsuMn", "QUZISRzFfoDctAR", "BvvXByzlXgGpOYO", "WYzKIDLTipUNvIY", "fbOZADViwISLtWN", "TgQkVlMefpLHCrr", "gVgPZGNKLlaKQoD", "kBekrqiYVggftXG", "NOYrObQidAUGlTB", "TmaKovMtlbLNsWh", "JJjTvSsSVpvXpav", "GmbZGngqsZePxGX", "YhypVQiWyGXLrGJ", "QTfOjdoqPslXPke", "sWmDwwCFJuiYNQl", "wPltmWZtpaPoXCP", "mVBlWpkYHqlswsv", "bndrStlvSfFnBGa", "bUTkOpQualSDhjm", "fXNOoDOvBSuhVrf", "GisrVJqShufcDge", "UgyyyYbSDlKPXJf", "HhsLbKbbpNUOXzp", "wZnYtzguPUBtUqy", "VYSYlDWdzxlPdvj", "aZSxgQPzIETFwHk", "tgSnGRhwuFYeBLK", "wlDSuLWJdbRlOlR", "WZNGYKfXGEFiEMG", "ypdEBHhCdTXpmxr", "nvkKDYWpAfJeOBP", "MTwFzjIlGPhirCg", "vlAWeqzYlwOKVNO", "PYGEbhnWLfyBmyl", "rfkcFMKHPXxgxrc", "gxDcivqbIYoiHCh", "NsJDJAZzOMsWyDs", "CofwBQFXKKytAPK", "esIAORejFlyShlh", "dQIMzaYhrYrwpDa", "kqsuNuKsWpfDkiN", "JshodjkBkvHmDjQ", "yyFNumGWyJVtHWQ", "lfmTnfdMTPqRISa", "CrzFwIjAEVrDEvc", "jdazMXXHzVNdAlL", "VfzwluLNKcvSfAG"]
var my_ssm = newSSM("ssms/test.ssm")
for i in 0..10_000:
  for key in keys:
    echo my_ssm.get(key)

