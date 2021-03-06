function W = GetPreW_BD(train, test)
% support by nn
    train_descr  = train.descr;
    train_label  = train.label;
    test_descr   = test.descr;
    test_label   = test.label;
    clear train test;
    Utr_label = unique(train_label);
    class_num  = length(unique(test_label));
%     errors = zeros(class_num, length(test_label));
%     acc_max = 0;
    K = 0.1:0.2:0.9;
    test_cell = num2cell(test_descr, 1);
    Dist_cell = arrayfun(@(t) sum((cell2mat(t)-train_descr).^2, 1), test_cell, 'UniformOutput',false);
    Dist_class_cell = arrayfun(@(dist) ...
                    arrayfun(@(i) dist{1}(train_label==i), Utr_label, 'UniformOutput',false), ...
                    Dist_cell, 'UniformOutput',false);
    [~, Ind_class_cell] = arrayfun(@(dist_c) ...
                        arrayfun(@(i) sort(dist_c{1}{i}), Utr_label, 'UniformOutput',false), ... 
                        Dist_class_cell, 'UniformOutput',false);

    mean_class_cell = arrayfun(@(k) ...
                    arrayfun(@(dist_c, ind_c) ...
                        arrayfun(@(dis_c, in_c) ...
                            mean(dis_c{1}(in_c{1}(1:ceil(length(in_c{1})*k)))), ...
                            dist_c{1}, ind_c{1}, 'UniformOutput',false) ...
                        , Dist_class_cell, Ind_class_cell, 'UniformOutput',false), ...
                    K, 'UniformOutput',false);

    [~, Ind_label_cell] = arrayfun(@(mean_c) ...
                        arrayfun(@(mea_c) min(cell2mat(mea_c{1})), ...
                            mean_c{1}, 'UniformOutput',false) ...
                        , mean_class_cell, 'UniformOutput',false);
    Pre_label_cell = arrayfun(@(ind_l) ...
                   arrayfun(@(in_l) Utr_label(in_l{1}), ...
                       ind_l{1}, 'UniformOutput',false) ...
                   , Ind_label_cell, 'UniformOutput',false);
    Acc_cell = arrayfun(@(pre_l) sum(test_label==cell2mat(pre_l{1}))/length(test_label)*100 ...
             , Pre_label_cell, 'UniformOutput',false);
    [~, index] = max(cell2mat(Acc_cell));
    mean_class_cell = mean_class_cell{index};
    max_class_cell = arrayfun(@(mean_c) max(cell2mat(mean_c{1})) ...
                   , mean_class_cell, 'UniformOutput',false);
    W_cell = arrayfun(@(mean_c, max_c) cell2mat(mean_c{1})/max_c{1} ...
           , mean_class_cell, max_class_cell, 'UniformOutput',false);
    for i = 1 : length(W_cell)
        W(:, i) = W_cell{i}; 
    end
%         [~, pre_label] = min(errors);
%         acc = sum(pre_label==test_label) / length(test_label);
%         if acc_max < acc
%            acc_max = acc;
%            W = errors;
%         end
    
end


