# ORCA: an image processing toolbox for Online Real-time activity and offline Cross-session Analysis

> Related paper: Sheng W, Zhao X, Huang X and Yang Y (2022) Real-Time Image Processing Toolbox for All-Optical Closed-Loop Control of Neuronal Activities. Front. Cell. Neurosci. 16:917713. doi: 10.3389/fncel.2022.917713

## Quick Start

If you want to...

- Use/Embed ORCA online with MATLAB-controlled imaging softwares, see `QS_online_MATLAB.m` code.
- Use ORCA online with other imaging softwares (most commercial solutions and every software that do not have direct access to MATLAB memory), see `QS_online_universal.m` code.
- Use ORCA offline, see `QS_offline.m` code.
- Use a part/module of ORCA, see `QS_API.m` code.

## Functionality

- `orca_registration` module for fast registration
   - inspired by the [moco](https://github.com/NTCColumbia/moco) algorithm
   - provides both CPU and GPU version
- `orca_segmentation` module for mask segmentation
   - two algorithms for online segmentation
   - [HNCcorr](https://github.com/hochbaumGroup/HNCcorr) matlab version for offline segmentation
   - other algorithms are also supported
   - tuning function `orcaui_tuning_segment_mask` available for testing optimal parameters
- `orca_trace_extraction` module for trace extraction
- `orca_cross_session` module for offline cross-session alignment

These four modules can be used standalone or embedded in any matlab-based pipeline.

- `orcapipe_online` are pipeline functions for online processing
   - `init_orca_online` defines most acquisition parameters required by the pipeline. **It is strongly recommended to go through this file to understand how to configure ORCA online**.
   - `orca_online_worker` is a background callback for processing newly acquired frames. The software provides two ways to be notified of new images:
      - Refresh (if `ORCA.Data` can be directly accessed by imaging system)
      - FileChanged (if the imaging system can only write new frames to disk)
   - `orcaui_online_worker` shows up if user interface is allowed. Note that updating UI information is time-consuming (costs 500~800ms on average) and is turned off by default.
- `orcapipe_offline` are pipeline functions for offline processing
   - This part is undergoing bugfixing and typesetting, and will be released soon.

## Requirements

- This software should run well on most modern PCs running Windows OS. It is developed on MATLAB R2017b, but any version later than R2016b should be okay.
- This software still works without Nvidia GPU. However most functions can be accelerated with [a valid graphical card](https://www.mathworks.com/help/parallel-computing/gpu-support-by-release.html) that can be recognized by MATLAB (see [gpuDevice](https://www.mathworks.com/help/parallel-computing/parallel.gpu.gpudevice.html)).

## Citation

If you find this work helpful, please consider citing the corresponding paper:

Sheng, W., Zhao, X., Huang, X., & Yang, Y. (2022). Real-Time Image Processing Toolbox for All-Optical Closed-Loop Control of Neuronal Activities.  *Frontiers in cellular neuroscience*, *16* . ([Full-Text](https://www.frontiersin.org/articles/10.3389/fncel.2022.917713/full))

## License

GPLv3 - see LICENSE for more information.
