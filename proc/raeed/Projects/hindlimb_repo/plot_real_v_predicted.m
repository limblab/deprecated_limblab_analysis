function plot_real_v_predicted(real_act, model, position)

%find predicted value
pred_act = predict(model,position);

plot(pred_act,real_act,'o',pred_act,pred_act,'-')