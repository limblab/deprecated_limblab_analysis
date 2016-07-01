numlags=10;
[H2long timerun] = hybridTrain(HybridFinal, numlags, 2);
[H6long timerun] = hybridTrain(HybridFinal, numlags, 6);
[H9long timerun] = hybridTrain(HybridFinal, numlags, 9);
[H11long timerun] = hybridTrain(HybridFinal, numlags, 11);

[H2short] = backslash(HybridFinal,numlags,2);
[HonIpredlong_2] = hybridTest(H2long, IsoTest,numlags,2);
[HonIpredshort_2] = hybridTest(H2short, IsoTest,numlags,2);

Pred = HonIpredlong_2; Act = IsoTest.emgdatabin(numlags:end,2);
HonI_vaf_long2 = calculateVAF(Pred,Act)

Pred = HonIpredshort_2; Act = IsoTest.emgdatabin(numlags:end,2);
HonI_vaf_short2 = calculateVAF(Pred,Act)

%

[H6short] = backslash(HybridFinal,numlags,6);
[HonIpredlong_6] = hybridTest(H6long, IsoTest,numlags,6);
[HonIpredshort_6] = hybridTest(H6short, IsoTest,numlags,6);

[HonWpredlong_6] = hybridTest(H9long, WmTest,numlags,6);
[HonWpredshort_6] = hybridTest(H9short, WmTest,numlags,6);

Pred = HonIpredlong_6; Act = IsoTest.emgdatabin(numlags:end,6);
HonI_vaf_long6 = calculateVAF(Pred,Act)

Pred = HonIpredshort_6; Act = IsoTest.emgdatabin(numlags:end,6);
HonI_vaf_short6 = calculateVAF(Pred,Act)

Pred = HonWpredlong_6; Act = WmTest.emgdatabin(numlags:end,6);
HonW_vaf_long6 = calculateVAF(Pred,Act)

Pred = HonWpredshort_6; Act = WmTest.emgdatabin(numlags:end,6);
HonW_vaf_short6 = calculateVAF(Pred,Act)

%

[H9short] = backslash(HybridFinal,numlags,9);
[HonIpredlong_9] = hybridTest(H9long, IsoTest,numlags,9);
[HonIpredshort_9] = hybridTest(H9short, IsoTest,numlags,9);
[HonWpredlong_9] = hybridTest(H9long, WmTest,numlags,9);
[HonWpredshort_9] = hybridTest(H9short, WmTest,numlags,9);


Pred = HonWpredlong_9; Act = WmTest.emgdatabin(numlags:end,9);
HonW_vaf_long9 = calculateVAF(Pred,Act)

Pred = HonWpredshort_9; Act = WmTest.emgdatabin(numlags:end,9);
HonW_vaf_short9 = calculateVAF(Pred,Act)


%

[H11short] = backslash(HybridFinal,numlags,11);
[HonIpredlong_11] = hybridTest(H11long, IsoTest,numlags,11);
[HonIpredshort_11] = hybridTest(H11short, IsoTest,numlags,11);
[HonWpredlong_11] = hybridTest(H11long, WmTest,numlags,11);
[HonWpredshort_11] = hybridTest(H11short, WmTest,numlags,11);

Pred = HonIpredlong_11; Act = IsoTest.emgdatabin(numlags:end,11);
HonW_vaf_long11 = calculateVAF(Pred,Act)

Pred = HonIpredshort_11; Act = IsoTest.emgdatabin(numlags:end,11);
HonW_vaf_short11 = calculateVAF(Pred,Act)

Pred = HonWpredlong_11; Act = WmTest.emgdatabin(numlags:end,11);
HonW_vaf_long11 = calculateVAF(Pred,Act)

Pred = HonWpredshort_11; Act = WmTest.emgdatabin(numlags:end,11);
HonW_vaf_short11 = calculateVAF(Pred,Act)
