function [cart_coefs] = fit_cartesian(zerod_ep,activity)

%     cart_fit = LinearModel.fit(zerod_ep,activity);
    cart_coefs = [ones(length(zerod_ep),1) zerod_ep]\activity;
    cart_coefs = cart_coefs';
end