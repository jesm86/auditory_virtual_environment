blocksize = [1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432];
seconds = [536.0172 ,273.2891, 137.6699, 70.3549, 34.0214, 18.1736, 9.0133, 5.2982, 3.3601, 2.6067, 2.2696, 4.087, 4.7861, 9.722, 19.789, 44.8572];

log2Blocksize = log2(blocksize);

loglog(2.^log2Blocksize, seconds, 'LineWidth', 2);


x_values = 10:25;  
customTicks = 2.^x_values;  
x_labels = arrayfun(@(x) sprintf('2^{%d}', x), x_values, 'UniformOutput', false);

set(gca, 'XTick', customTicks, 'XTickLabel', x_labels);x_labels = arrayfun(@(x) sprintf('2^{%d}', x), x_values, 'UniformOutput', false);
set(gca, 'XMinorTick', 'off');

xticklabels(x_labels);
set(gca, 'XTickMode', 'manual', 'XTick', customTicks, 'XTickLabel', x_labels);
title("Computation time of Overlap-save based FFT convolution of complete 30s audiofile depending on block size");
xlabel('Block size');
ylabel("t / s")
