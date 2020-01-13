# Reviewer(s)' Comments to Author:   
***
### Referee: 1     

1. <font color=red>No clear hypotheses, the biological or functional significance of DFC is not outlined, and major confounds are not ruled out</font>. <font color=red> It would seem important for the authors to first present “regular” functional connectivity before presenting DFC. </font> If this has already been presented from the current data, that should be made much clearer. Overall, additional methods and analyses are needed to convince the reader that these findings are robust and interpretable.   
> **见图1**  
- ![image](./Figure S1_Results_staticFC_submittingversion.tif)  
> 首先，我们的研究更倾向于是一种探索性的分析，即探索三种疾病是否在功能连接上有共同的异常。之所以选择动态的方法，是因为动态的方法可以提供功能连接更多的信息，比如全脑功能连接状态，状态之间的切换次数，状态驻留时间等（见第4条回复部分）。
> 其次，我们presenting the average static functional connectivity and the statistical results？


3. K means clustering will cluster data even when the underlying data structure is dimensional. <font color=red> The authors should explicitly compare a categorical model with a dimensional one (dimensional latent construct with multiple indicators).</font>  
> **见图2**  
>我使用了的因子分析（latent method）从所有窗口的动态连接中提取因子。为了与kmeans的结果有对比性，因子的数目由kmeans决定的最佳质点数K来决定。最终，我们提取了2个latent的factors,辅组材料中有这两个factors的图。我们可以发现，这2个由因子分析得到“脑状态”与我们的用kmeans发现的2个脑状态是基本一致的：一个是强的网络内正连接以及强的网络间负连接，另一个是弱的连接。

4. There is much discussion in the literature of DFC being an artifact of variations in arousal state over time.  How would the authors rule out this confound? 
doi: 10.1093/cercor/bhw265. 
doi: 10.3389/fnins.2019.01190 
doi: 10.1016/j.neuroimage.2019.07.004   

> **见图3**  
>的确，现在DFC领域存在争议。有人说DFC只是睡眠与否或者头动的一种反映。但是有更多的研究发现了DFC的生理学意义（包括DFC可以反映人的警觉
>水平）。举例:那篇NC的DFC文章，以及审稿人给出的下面这篇文章。 
>在被试的静息态扫描过程中，被试很难一直维持在高的警觉状态，警觉状态的波动本质上也是一种正常的现象（见我们的temploral_properties.C
>图）。
>首先，我们发现的两个状态是可以在不同的人群中得到重复的（NC的那一篇以及我们的交叉验证的结果）。其次，对于磁共振数据的采集来讲，在扫
>描开始我们会要求被试放松但是不要睡觉, 另外我们增加了temploral_properties的内容，进一步探索DFC的神经生理学意义。 
>1根据'Vigilance declines following sleep deprivation are associated with two previously identified dynamic 
>connectivity states', State1 可能是高警觉状态，State2可能倾向于是一个低警觉状态（跟static FC对比，发现state2与static 
>FC更加类似，spearmen相关性高）。  
>
>2根据1中的文献，state1可能倾向于是高警觉状态（高的网络内连接，以及高DMN与SN、VAN负连接）。而state2可能更倾向于是低警觉状态（weak 
>anti-correlations between taskpositive networks (dorsal attention network (DAN), ventral attention/salience network (
>VAN), executive control network (ECN)) and the default-mode network (DMN).）。
>
>3根据1，2以及图temploral_properties，我们可以做出推断：精神疾病（主要是SZ，其它两种又趋势，但是没有达到统计学意义水平）在高警
>觉状态驻留时间/分数时间都更多，而在应该维持的低警觉（静息状态）驻留时间更短。如果考虑到精神疾病患者相较于正常人来说更多疑，猜忌，被迫害妄想，
>以及对陌生环境更容易产生警觉,那么这个结果将不是一个非常出乎意料之外的。更有趣的是，病人所有的差异都只在低警觉状态（静息态）时表现出来，而在高警觉状态时，脑功能连接跟正常人没有统计学差异。这个结果可能提示了参与我们研究的精神疾病患者脑功能具有一定的正常功能储备，即在高的警觉状态脑功能可以维持在正常状态，但是在大多数非高警觉状态（或者静息态）基础脑功能时存在显著异常的。
>
>4根据图temploral_properties.C: 精神疾病患者的的状态转换更加频繁，可能间接反映了精神疾病患者的脑网络状态的破碎性。
>5 尽管我们更倾向于DFC是有神经生物学意义的， 但是正如您所言，我们毕竟没有同步记录脑电图来确保被试的动态觉醒状态。因此我们将这一点写入到limitations中，以便提示读者需要考虑。

5. What is the <font color=red>biological interpretation or meaningfulness of these different states?</font>  
> 根据第4条的的回复，State1可能代表患者处于一个高警觉、不安的的状态，而state2 可能代表一个低警觉状态的，静息的状态。
> 严格的生物学意义还需要进一步的探索。

6. The hypotheses were very vague – only stating that there were be shared dysconnectivity in “many brain networks.”
>前面加一句我们的研究是探索性的分析？ 

7. It is fine to do exploratory analyses, but then the authors should be using methods that deal with the robustness of exploratory analyses.  FDR correction is not enough, there really should be <font color=red>cross-validation and ideally a held out sample to address generalization and replicability</font>>.   The current methods do not lend confidence that these “states” are robust or replicable. 
> **见图4**   
> 1用一部分其它正常人来验证结果:其中HC=115, SZ=12, BD=11, MDD=33. 
> 2The human cortex possesses a reconfigurable dynamic network architecture that is disrupted in psychosis 
> 这篇文章发现2-20这么多个状态中，2，4，5，8状态最稳定。 而且我们的2状态网络跟他们的非常类似，state1跟静态网络像 （muted 
> fc），而state2跟他们的state2是对应的（强网络内连接，以及强的DMN与SN及DAN负连接）

8. The only demographic data reported is age and gender.  Information is needed on developmental SES to assure the reader that this is not a major confound, since brain connectivity is also associated with poverty and adversity.   
> **见图5**     
>**找几个相关的指标跟有统计学意义的连接做相关**

9. The authors did a nice job on the functional connectivity preprocessing in terms of addressing motion related confounds.   

10. This sentence is difficult to follow: “Interestingly, the patterns of dysconnectivity were consistent across the three psychiatric disorders, i.e., they were either higher or lower than that of HC” 
> **修改到更易懂**。

***
## Referee: 2 
In this manuscript the authors investigate dynamic functional connectivity differences in a relatively large patient sample. This paper is timely given the increased emphasis on transdiagnostic etiology of mental illness, and the analyses are generally appropriate. They provide a nice descriptive analysis of DFC differences between groups. There are a few methodological gaps and open questions I have outlined below. 

1. “if the outliers accounted for > 30% of all volumes (190 volumes)” 
• How were outliers defined? What was the cutoff for an outlier? Was it based on FD or something else? 
• How was this cutoff justified and why 30%? 
>30%是指FD大于0.2的volumes 比例
>这个cutoff是根据领域内的文献来定义的

2. Why was the silhouette out of all clustering validity metrics? I have no problem with silhouette, it just should be justified, and the reasoning should be explained to the reader. 
>受人主观影响少？借鉴Brain的文章。

3. <font color=red> What were the silhouette values for k-means of 2-10? This should reported as a table or figure in the supplemental or main text </font>
> 见图6     
>已经silhouette values 保存起来，然后做成图。

4. <font color=red> Was anything done to account for the fact that lower numbers of clusters tend to be more similar. Using raw cluster validity metrics can therefore be biased towards selecting lower numbers of clusters. Some research use an elbow method or local minimum method or something similar to adjust for this. Was anything like this considered? </font>
> **见图7**     
>1用matlab自带的数据集（iris）来说明不是lower number 导致more similar.2交叉验证的说明2个类比较稳定。

5. “We found that all participants experienced two distinct functional connectivity states during the resting state scanning: state 1, a less frequent, 'extreme' state characterized by stronger positive and negative connectivity, and state 2, a more frequent, moderate state with weaker connectivity.” 
• Does k-means really mean that these 2-states are present in ALL individuals? Did you test this? Could it have been the case that some subjects did not experience 2-states given your analysis methods or is this outcome guaranteed given the methods? In other words, are the 2 states summaries across the group, instead of individually identifiable in every subject? 
>这里的表述确实有逻辑问题。实际上，并不是每个人都能经历2个状态。在我们的研究中，有543个人经历状态1，有605个人经历了状态2.
>我们已经将文章中的表述做了修改：***。

6. In the discussion the authors seem to focus on a handful on networks including the FPN, DMN and sensory networks. However, as far as I can tell there are significant group differences in edges that fall within every network and nearly every within and between network connection. Why were specific network differences emphasized? <font color=red> The authors should consider formally testing whether significant edges tended to fall within specific networks than would be expected by chance. There are more edges in some networks, and networks have structured spatial patterns. Therefore if the authors want to make inferences about certain networks being overrepresented they should formally test this and use statistical methods that account for spatial autocorrelation. See examples and methodological implementation of this method below: </font>
> **见图8**     
   >Alexander-Bloch et al., “On testing for spatial correspondence between maps of human brain structure and function.”  Neuroimage 2018   
   >Reardon et al., “Normative brain size variation and brain shape diversity in humans.” Science 2018. 
7. The discussion should reflect the results of these formal tests for network specificity or remain more descriptive and avoid overemphasizing specific network connections.
>6和7的问题本质是一个问题。目前，我已经根据这两篇文献中的方法做了置换检验。我们生成与真实网络同样节点数，同样的连接数，以及同样的度分布的5000个随机网络。将真实网络中落在各个子网络的差异连接对子数与随机网络中的进行对比，我们得到了各个子网络差异连接对子数是否具有统计学差异。
