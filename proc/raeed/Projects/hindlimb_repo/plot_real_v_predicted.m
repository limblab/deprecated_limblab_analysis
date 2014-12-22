function plot_real_v_predicted(real_act, model, position)

%find predicted value
pred_act = predict(model,position);

plot(real_act,pred_act,'o',real_act,real_act,'-')