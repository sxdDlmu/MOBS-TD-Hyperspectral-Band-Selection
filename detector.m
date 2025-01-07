function [ output ] = detector (img, target, detector_Name)
%{ 
    Replication of 4 classical hyperspectral target detection algorithms. Referencing the code provided by Ayan Chatterjee.
    Please consider citing the following literature if it can help your work:
    Reference: X. Sun, P. Lin, X. Shang, H. Pang and X. Fu, "MOBS-TD: Multiobjective 
               Band Selection With Ideal Solution Optimization Strategy for Hyperspectral 
               Target Detection,” IEEE Journal of Selected Topics in Applied Earth 
               Observations and Remote Sensing (IEEE JSTARS), DOI: 10.1109/JSTARS.2024.3402381.
 %}
if strcmp(detector_Name,'CEM')
    disp('Using CEM detector...');
    [ output ] = hyperCem(img',target);
else if strcmp(detector_Name,'AMF')
        disp('Using AMF detector...');
        [ output ] = AMF(img,target);
    else if strcmp(detector_Name,'ACE_w')
            disp('Using ACE whitening detector...');
            [ output ] = ACE_whitening(img,target);
        else if strcmp(detector_Name,'ACE_g')
                disp('Using ACE globalmean detector...');
                [ output ] = ACE_globalmean(img,target);
            end
        end
    end
end
end

%% detectors

function output = ACE_whitening(image, target)
    im_cov = cov(image); 
    [U, S, V] = svd(im_cov);
    inv_cov = pinv(U * sqrt(S) * V');
    whitened_image = inv_cov * image';
    whitened_target = inv_cov * target;
    output = (whitened_target' * whitened_image).^2 ./ ((whitened_target' * whitened_target) .* sum(whitened_image .* whitened_image));
end

function output = ACE_globalmean(image, target)
    mean_image = mean(image); 
    inv_cov = pinv(cov(image)); 
    demeaned_target = target' - mean_image;
    demeaned_image = image - mean_image;
    numerator = demeaned_target * inv_cov * demeaned_image';
    denominatorL = demeaned_target * inv_cov * demeaned_target';
    denominatorR = sum((demeaned_image * inv_cov) .* demeaned_image, 2);
    output = numerator.^2 ./ (denominatorL * denominatorR'); 
end

function output = AMF(image, target)
    mean_image = mean(image); 
    inv_cov = pinv(cov(image)); 
    demeaned_target = target' - mean_image;
    demeaned_image = image - mean_image;
    target_invCov_project = demeaned_target * inv_cov;
    denominator = target_invCov_project * demeaned_target';
    output = target_invCov_project * demeaned_image' / denominator;
end
